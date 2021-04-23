//
//  PresentationAnimator.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/23.
//

import UIKit

public enum TransitionType {
    case presenting
    case dismissing
}

public protocol CustomPresentableViewController: PresentationAnimator, UIViewController { }

public protocol PresentationAnimator: AnyObject {
    /// 通过该方法返回动画配置
    ///
    /// 该方法有一个默认实现返回默认值，因此该方法是可选的（optional）
    ///
    /// - Returns: 浮动面板显示隐藏时的动画配置
    func presentationAnimationConfigs() -> AnimationConfig
    
    /// 转场动画开始之前该方法将被调用
    ///
    /// 该方法有一个默认的空实现，因此该方法是可选的（optional）
    ///
    /// - Parameter type: 即将开始的转场类型
    func presentationWillBeginTransition(type: TransitionType)
    
    /// 通过该方法更新浮动面板显示和隐藏时的约束值或其他属性
    ///
    /// - Parameters:
    ///   - type: 当前要执行的转场动画类型
    ///   - duration: 动画的总持续时长，该值与presentationAnimationConfigs中返回的值一致
    ///   - completeCallback: 当动画结束时需要调用该闭包通知transitioningManager动画已结束
    func presentationUpdateViewsForTransition(type: TransitionType, duration: TimeInterval, completeCallback: @escaping () -> Void)
    
    /// 转场动画结束时该方法将被调用
    ///
    /// 该方法有一个默认的空实现，因此该方法是可选的（optional）
    ///
    /// - Parameters:
    ///   - type: 已结束的转场类型
    ///   - wasCancelled: 是否中途被取消
    func presentationDidEndTransition(type: TransitionType, wasCancelled: Bool)
}

extension PresentationAnimator {
    func presentationAnimationConfigs() -> AnimationConfig { .default }
    func presentationWillBeginTransition(type: TransitionType) { }
    func presentationDidEndTransition(type: TransitionType, wasCancelled: Bool) { }
}

public struct AnimationConfig {
    
    public static var `default`: AnimationConfig = {
        return AnimationConfig()
    }()
    
    /// 遮罩类型
    public enum MaskType {
        /// 无遮罩
        case none
        /// 黑色半透明遮罩
        case black(alpha: CGFloat)
        /// 指定颜色的遮罩
        case color(color: UIColor)
    }
    
    /// present时的动画持续时间，默认值为0.35秒
    public var duration: TimeInterval = 0.35
    /// dismiss时的动画持续时间，若为nil则使用duration的值
    public var durationForDismissing: TimeInterval?
    /// 遮罩类型，默认值是alpha值为0.5的半透明黑色，
    public var maskType: MaskType = .black(alpha: 0.5)
    
    /// 可调整展示区域，默认nil不调整
    public var targetFrame: CGRect?
    /// 展示样式，默认为overFullScreen，可根据需求调整
    public var presentationStyle: UIModalPresentationStyle = .overFullScreen
    
    public init() { }
}

// MARK: - Present
extension UIViewController {
    public func present(_ viewController: CustomPresentableViewController,
                        animated: Bool,
                        completion: (() -> Void)?) {
        viewController.configPresentationAnimator(with: nil)
        present(viewController as UIViewController, animated: animated) {
            viewController.transitioningManager?.interactivePresentingTransition = nil
            completion?()
        }
    }
    
    public func present(_ viewController: CustomPresentableViewController,
                        interactiveTransition: UIViewControllerInteractiveTransitioning? = nil,
                        animated: Bool,
                        completion: (() -> Void)?) {
        viewController.configPresentationAnimator(with: interactiveTransition)
        present(viewController as UIViewController, animated: animated) {
            viewController.transitioningManager?.interactivePresentingTransition = nil
            completion?()
        }
    }
    
    public func present(_ viewController: UIViewController,
                        animator: PresentationAnimator,
                        completion: (() -> Void)?) {
        viewController.configPresentationAnimator(animator, interactiveTransition: nil)
        present(viewController as UIViewController, animated: true) {
            viewController.transitioningManager?.interactivePresentingTransition = nil
            completion?()
        }
    }
    
    public func present(_ viewController: UIViewController,
                        interactiveTransition: UIViewControllerInteractiveTransitioning? = nil,
                        animator: PresentationAnimator,
                        completion: (() -> Void)?) {
        viewController.configPresentationAnimator(animator, interactiveTransition: interactiveTransition)
        present(viewController as UIViewController, animated: true) {
            viewController.transitioningManager?.interactivePresentingTransition = nil
            completion?()
        }
    }
}

// MARK: - Dismiss
public extension CustomPresentableViewController where Self: UIViewController {
    /// 隐藏浮动面板（可交互的）
    ///
    /// - Parameters:
    ///   - interactiveTransition: 传入一个交互控制器，在外部通过该对象去控制当前dismiss的进度
    ///   - animated: 是否展示动画
    ///   - completion: dismiss结束的回调
    func dismiss(with interactiveTransition: UIViewControllerInteractiveTransitioning,
                 animated: Bool,
                 completion: (() -> Void)?) {
        if let nav = navigationController, let transitioningManager = nav.transitioningManager {
            transitioningManager.interactiveDismissingTransition = interactiveTransition
            nav.dismiss(animated: true) {
                transitioningManager.interactiveDismissingTransition = nil
                completion?()
            }
        } else {
            transitioningManager?.interactiveDismissingTransition = interactiveTransition
            dismiss(animated: animated) {
                self.transitioningManager?.interactiveDismissingTransition = nil
                completion?()
            }
        }
    }
}

// MARK: - Private
extension CustomPresentableViewController where Self: UIViewController {
    fileprivate func configPresentationAnimator(with interactiveTransition: UIViewControllerInteractiveTransitioning?) {
        let config = presentationAnimationConfigs()
        let transitioningManager = PresentationTransitioning(animator: self, config: config)
        transitioningManager.interactivePresentingTransition = interactiveTransition
        modalPresentationStyle = config.presentationStyle
        transitioningDelegate = transitioningManager
        modalPresentationCapturesStatusBarAppearance = true
        self.transitioningManager = transitioningManager
    }
}

extension UIViewController {
    fileprivate func configPresentationAnimator(_ animator: PresentationAnimator,
                                                interactiveTransition: UIViewControllerInteractiveTransitioning?) {
        let config = animator.presentationAnimationConfigs()
        let transitioningManager = PresentationTransitioning(animator: animator, config: config)
        transitioningManager.interactivePresentingTransition = interactiveTransition
        modalPresentationStyle = config.presentationStyle
        transitioningDelegate = transitioningManager
        modalPresentationCapturesStatusBarAppearance = true
        self.transitioningManager = transitioningManager
    }
}

private var TransitioningManagerKey = "TransitioningManagerKey"
extension UIViewController {
    fileprivate var transitioningManager: PresentationTransitioning? {
        get {
            return objc_getAssociatedObject(self, &TransitioningManagerKey) as? PresentationTransitioning
        }
        set {
            objc_setAssociatedObject(self, &TransitioningManagerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private class PresentationTransitioning: NSObject, UIViewControllerTransitioningDelegate {
    
    var interactivePresentingTransition: UIViewControllerInteractiveTransitioning?
    var interactiveDismissingTransition: UIViewControllerInteractiveTransitioning?
    let animator: PresentationTransitioningAnimator
    
    init(animator presentationAnimator: PresentationAnimator, config: AnimationConfig) {
        animator = PresentationTransitioningAnimator(animator: presentationAnimator, config: config)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.transitionType = .presenting
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.transitionType = .dismissing
        return animator
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactivePresentingTransition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveDismissingTransition
    }
    
}

private class PresentationTransitioningAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    unowned var animator: PresentationAnimator
    var transitionType: TransitionType = .presenting
    
    let config: AnimationConfig
    
    init(animator: PresentationAnimator, config: AnimationConfig) {
        self.animator = animator
        self.config = config
    }
    
    private lazy var maskView: UIView = UIView()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return config.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let transitionType = self.transitionType
        guard let view = transitionContext.view(forKey: transitionType.viewKey) else {
            return
        }
        let container = transitionContext.containerView
        if let targetFrame = config.targetFrame {
            container.frame = targetFrame
        }
        view.frame = container.bounds
        updateMask(for: transitionType, container: container)
        container.addSubview(view)
        
        animator.presentationWillBeginTransition(type: transitionType)
        
        let duration: TimeInterval
        switch transitionType {
        case .presenting: duration = config.duration
        case .dismissing: duration = config.durationForDismissing ?? config.duration
        }
        
        animator.presentationUpdateViewsForTransition(type: transitionType, duration: duration) {
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
            self.animator.presentationDidEndTransition(type: transitionType, wasCancelled: wasCancelled)
        }
    }
    
    private func updateMask(for transitionType: TransitionType, container: UIView) {
        if case .none = config.maskType {
            return
        }
        switch transitionType {
        case .presenting:
            maskView.backgroundColor = config.maskType.maskColor
            maskView.frame = container.bounds
            maskView.alpha = 0
            container.addSubview(maskView)
            UIView.animate(withDuration: config.duration) {
                self.maskView.alpha = 1
            }
        case .dismissing:
            UIView.animate(withDuration: config.durationForDismissing ?? config.duration) {
                self.maskView.alpha = 0
            }
        }
    }
}

private extension TransitionType {
    var viewKey: UITransitionContextViewKey {
        switch self {
        case .presenting: return .to
        case .dismissing: return .from
        }
    }
}

private extension AnimationConfig.MaskType {
    var maskColor: UIColor {
        switch self {
        case .none: return .clear
        case let .black(alpha): return UIColor(white: 0, alpha: alpha)
        case let .color(color): return color
        }
    }
}
