//
//  EmojiPickerWindow.swift
//  EmojiPickerUI
//
//  Created by Guilherme Rambo on 25/05/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

import UIKit

struct EmojiSnapshot {
    let image: UIImage
    let frame: CGRect
}

@objc protocol DraggableTarget {
    func handleDrag(with recognizer: UIPanGestureRecognizer)
}

final class EmojiPickerWindow: UIWindow, DraggableTarget {

    override var isHidden: Bool {
        didSet {
            guard isHidden != oldValue, !isHidden else { return }

            setupLook()
        }
    }

    private func setupLook() {
        layer.cornerRadius = EmojiPickerMetrics.cornerRadius
        layer.cornerCurve = .continuous
        layer.masksToBounds = false
        backgroundColor = .systemBackground

        NotificationCenter.default.addObserver(self, selector: #selector(receiveEmojiSnapshot), name: .FloatingEmojiPickerDidSnapshotSelectedEmoji, object: nil)
    }

    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 22
        layer.shadowOffset = CGSize(width: 1, height: 1)
    }

    private var currentAnimator: UIViewPropertyAnimator?

    private var caretPosition: CGPoint = .zero
    private var hiddenFrame: CGRect = .zero

    private lazy var rootSnapshotView: UIView = {
        let v = UIView()
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return v
    }()

    private lazy var selectedEmojiSnapshotView: UIView = {
        let v = UIView()
        v.autoresizingMask = []
        return v
    }()

    @objc private func receiveEmojiSnapshot(_ note: Notification) {
        guard let snap = note.object as? EmojiSnapshot else { return }

        selectedEmojiSnapshotView.layer.contents = snap.image.cgImage
        selectedEmojiSnapshotView.frame = snap.frame
    }

    private func cancelPendingAnimation() {
        guard let anim = currentAnimator, anim.state != .stopped else { return }

        currentAnimator?.stopAnimation(true)
        currentAnimator = nil
    }

    func animateIn(from input: UITextInput & UIView) {
        cancelPendingAnimation()

        guard let caret = input.findCaret()?.subviews.first else {
            isHidden = false
            return
        }

        guard let refWindow = input.window else { return }

        caretPosition = input.convert(caret.frame.origin, to: refWindow)

        hiddenFrame = CGRect(
            x: caretPosition.x - caret.frame.width/2,
            y: caretPosition.y - caret.frame.height/2,
            width: caret.frame.width,
            height: caret.frame.height
        )

        var finalFrame = CGRect(
            x: caretPosition.x - EmojiPickerMetrics.windowSize.width/2,
            y: caretPosition.y - EmojiPickerMetrics.windowSize.height - EmojiPickerMetrics.verticalMarginFromCaret,
            width: EmojiPickerMetrics.windowSize.width,
            height: EmojiPickerMetrics.windowSize.height
        )

        finalFrame = validateFrame(finalFrame, adjustY: { [weak self] validFrame in
            guard let self = self else { return }

            validFrame.origin.y = self.caretPosition.y + EmojiPickerMetrics.verticalMarginFromCaret
        })

        guard !UIAccessibility.isReduceMotionEnabled else {
            frame = finalFrame
            isHidden = false
            return
        }

        let finalBackgroundColor = backgroundColor

        frame = hiddenFrame

        backgroundColor = caret.backgroundColor

        isHidden = false

        let curve = FluidTimingCurve(velocity: CGVector(dx: 0.7, dy: 0.7))

        currentAnimator = UIViewPropertyAnimator(duration: 0, timingParameters: curve)

        currentAnimator?.addAnimations {
            self.addShadow()
            self.frame = finalFrame
            self.backgroundColor = finalBackgroundColor
        }

        currentAnimator?.addAnimations({
            if let participant = self.rootViewController as? EmojiPickerTransitionParticipant {
                participant.performEmojiPickerTransition()
            }
        }, delayFactor: 0.3)

        currentAnimator?.startAnimation()
    }

    func animateOut(into input: UITextInput & UIView, insertEmoji: @escaping () -> Void, completion: @escaping () -> Void) {
        guard !UIAccessibility.isReduceMotionEnabled else {
            insertEmoji()
            isHidden = true
            completion()
            return
        }

        cancelPendingAnimation()

        guard let contentView = rootViewController?.view else { return }

        let renderer = UIGraphicsImageRenderer(bounds: contentView.bounds, format: .init(for: contentView.traitCollection))

        let contentImage = renderer.image { ctx in
            contentView.layer.render(in: ctx.cgContext)
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationDuration(0)

        rootSnapshotView.layer.cornerRadius = EmojiPickerMetrics.cornerRadius
        rootSnapshotView.layer.cornerCurve = .continuous
        rootSnapshotView.layer.masksToBounds = true
        rootSnapshotView.layer.contents = contentImage.cgImage
        rootSnapshotView.frame = bounds

        addSubview(rootSnapshotView)
        addSubview(selectedEmojiSnapshotView)
        contentView.removeFromSuperview()

        CATransaction.commit()

        let curve = FluidTimingCurve(velocity: CGVector(dx: 0.7, dy: 0.7))
//        let curve = UICubicTimingParameters(animationCurve: .easeInOut)

        currentAnimator = UIViewPropertyAnimator(duration: 0, timingParameters: curve)

        currentAnimator?.addAnimations {
            self.layer.shadowOpacity = 0
            self.frame = self.hiddenFrame

            self.rootSnapshotView.alpha = 0
            self.rootSnapshotView.frame = CGRect(origin: .zero, size: self.hiddenFrame.size)

            self.selectedEmojiSnapshotView.frame = CGRect(
                x: 0,
                y: 0,
                width: self.selectedEmojiSnapshotView.frame.width*0.6,
                height: self.selectedEmojiSnapshotView.frame.height*0.6
            )
            self.selectedEmojiSnapshotView.alpha = 0
        }

        currentAnimator?.addAnimations({
            insertEmoji()
        }, delayFactor: 0.8)

        currentAnimator?.addCompletion { _ in
            self.isHidden = true
            completion()
        }

        currentAnimator?.startAnimation()
    }

    func dismiss(completion: @escaping () -> Void) {
        guard !UIAccessibility.isReduceMotionEnabled else {
            isHidden = true
            return
        }

        cancelPendingAnimation()

        let curve = UICubicTimingParameters(animationCurve: .easeInOut)
        currentAnimator = UIViewPropertyAnimator(duration: 0.3, timingParameters: curve)

        currentAnimator?.addAnimations {
            self.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1)
            self.alpha = 0
        }

        currentAnimator?.addCompletion { _ in
            self.isHidden = true
            completion()
        }

        currentAnimator?.startAnimation()
    }

    private func rubberBandValue(for position: CGFloat, limit: CGFloat) -> CGFloat {
        limit * (1 + log10(position/limit))
    }

    private lazy var extrapolatedFrame: CGRect = { frame }()

    private var effectiveScreenHeight: CGFloat {
        let margin: CGFloat = 36

        guard let screen = windowScene?.screen else { return UIScreen.main.bounds.height - margin }

        return screen.bounds.height - margin
    }

    func handleDrag(with recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: nil)

        switch recognizer.state {
        case .began:
            extrapolatedFrame = frame
        case .changed:
            var f = frame

            f.origin.x += translation.x
            f.origin.y += translation.y

            extrapolatedFrame.origin.x += translation.x
            extrapolatedFrame.origin.y += translation.y

            // Rubber band when going beyond allowed screen edges

            if extrapolatedFrame.origin.x + extrapolatedFrame.width > screen.bounds.width {
                f.origin.x = rubberBandValue(for: (extrapolatedFrame.origin.x + extrapolatedFrame.width), limit: screen.bounds.width) - extrapolatedFrame.width
            }
            if extrapolatedFrame.origin.y + extrapolatedFrame.height > effectiveScreenHeight {
                f.origin.y = rubberBandValue(for: (extrapolatedFrame.origin.y + extrapolatedFrame.height), limit: effectiveScreenHeight) - extrapolatedFrame.height
            }
            if extrapolatedFrame.origin.y < 0 {
                f.origin.y = -rubberBandValue(for: abs(extrapolatedFrame.origin.y), limit: EmojiPickerMetrics.marginFromScreenEdges)
            }
            if extrapolatedFrame.origin.x < 0 {
                f.origin.x = -rubberBandValue(for: abs(extrapolatedFrame.origin.x), limit: EmojiPickerMetrics.marginFromScreenEdges)
            }

            frame = f
        case .ended, .cancelled, .failed:
            snapToValidFrame()
        default:
            break
        }

        recognizer.setTranslation(.zero, in: nil)
    }

    private func validateFrame(_ subject: CGRect, adjustY: ((inout CGRect) -> Void)? = nil) -> CGRect {
        guard let screen = windowScene?.screen else { return subject }

        var f = subject

        if f.origin.x - EmojiPickerMetrics.marginFromScreenEdges < 0 {
            f.origin.x = EmojiPickerMetrics.marginFromScreenEdges
        }
        if f.origin.x + f.width > screen.bounds.width {
            f.origin.x = screen.bounds.width - f.width - EmojiPickerMetrics.marginFromScreenEdges
        }
        if f.origin.y - EmojiPickerMetrics.marginFromScreenEdges < 0 {
            if let adjustY = adjustY {
                adjustY(&f)
            } else {
                f.origin.y = EmojiPickerMetrics.marginFromScreenEdges
            }
        }
        if f.origin.y + f.height > effectiveScreenHeight {
            f.origin.y = effectiveScreenHeight - f.height - EmojiPickerMetrics.marginFromScreenEdges
        }

        return f
    }

    private func snapToValidFrame() {
        cancelPendingAnimation()

        let validFrame = validateFrame(frame)

        let curve = FluidTimingCurve(velocity: CGVector(dx: 0.7, dy: 0.7))

        currentAnimator = UIViewPropertyAnimator(duration: 0, timingParameters: curve)

        currentAnimator?.addAnimations {
            self.frame = validFrame
        }

        currentAnimator?.startAnimation()
    }

}
