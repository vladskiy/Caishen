//
//  FloatingLabelTextFieldWithIcon.swift
//  Caishen
//
//  Created by Vladyslav Lypskyi on 30/03/2017.
//  Copyright © 2017 Prolific Interactive. All rights reserved.
//

import Foundation

/// Floating label text field with right icon
open class FloatingLabelTextFieldWithIcon: FloatingLabelTextField {
    
    
    /// Optional icon view
    open var iconView: UIImageView!
    
    /// A bool value which determines position of the icon relatively to clear button
    @IBInspectable
    open var iconToRightOfClear: Bool = true {
        didSet {
            updateFrame()
        }
    }
    
    /// A float value that determines the left margin of the icon. Use this value to position the icon more precisely horizontally.
    @IBInspectable
    open var iconMarginLeft: CGFloat = 0 {
        didSet {
            updateFrame()
        }
    }
    
    /// A float value that determines the right margin of the icon. Use this value to position the icon more precisely horizontally.
    @IBInspectable
    open var iconMarginRight: CGFloat = 0 {
        didSet {
            updateFrame()
        }
    }
    
    /// A float value that determines the bottom margin of the icon. Use this value to position the icon more precisely vertically.
    @IBInspectable
    open var iconMarginBottom: CGFloat = 0 {
        didSet {
            updateFrame()
        }
    }
    
    // MARK: Initializers
    
    /**
     Initializes the control
     - parameter frame the frame of the control
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createIconView()
    }
    
    /**
     Intialzies the control by deserializing it
     - parameter coder the object to deserialize the control from
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createIconView()
    }
    
    // MARK: Creating the icon view
    
    /// Creates the icon view
    fileprivate func createIconView() {
        let iconView = UIImageView(frame: CGRect.zero)
        iconView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        self.addSubview(iconView)
        self.iconView = iconView
    }
    
    /**
     Calculate the bounds for the textfield component of the control. Override to create a custom size textbox in the control.
     - parameter bounds: The current bounds of the textfield component
     - returns: The rectangle that the textfield component should render in
     */
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        guard let iconSize = iconView?.intrinsicContentSize,
            iconSize.width != UIViewNoIntrinsicMetric
                && iconSize.height != UIViewNoIntrinsicMetric else {
                    return rect
        }
        rect.size.width -= CGFloat(iconSize.width + iconMarginLeft + iconMarginRight)
        return rect
    }
    
    /**
     Calculate the rectangle for the textfield when it is being edited
     - parameter bounds: The current bounds of the field
     - returns: The rectangle that the textfield should render in
     */
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        guard let iconSize = iconView?.intrinsicContentSize,
            iconSize.width != UIViewNoIntrinsicMetric
                && iconSize.height != UIViewNoIntrinsicMetric else {
                    return rect
        }
        rect.size.width -= CGFloat(iconSize.width + iconMarginLeft + iconMarginRight)
        return rect
    }
    
    /**
     Calculates the bounds for the placeholder component of the control. Override to create a custom size textbox in the control.
     - parameter bounds: The current bounds of the placeholder component
     - returns: The rectangle that the placeholder component should render in
     */
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.placeholderRect(forBounds: bounds)
        guard let iconSize = iconView?.intrinsicContentSize,
            iconSize.width != UIViewNoIntrinsicMetric
                && iconSize.height != UIViewNoIntrinsicMetric else {
                    return rect
        }
        rect.size.width -= CGFloat(iconSize.width + iconMarginLeft + iconMarginRight)
        return rect
    }
    
    override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        
        guard iconToRightOfClear == true else {
            // Nothing to change, leave in default position
            return rect
        }
        
        guard let iconSize = iconView?.intrinsicContentSize,
            iconSize.width != UIViewNoIntrinsicMetric
                && iconSize.height != UIViewNoIntrinsicMetric else {
                    return rect
        }
        
        let offset = iconMarginLeft + iconMarginRight + iconSize.width
        rect.origin.x -= isLTRLanguage ? offset : -offset
        return rect
    }
    
    /**
     Calculates the bounds for the icon image view.
     - parameter bounds: The current bounds of the component
     - returns: The rectangle that the icon component should render in
     */
    open func iconRect(forBounds bounds: CGRect) -> CGRect {
        guard let iconSize = iconView?.intrinsicContentSize,
            iconSize.width != UIViewNoIntrinsicMetric
                && iconSize.height != UIViewNoIntrinsicMetric else {
                    return CGRect.zero
        }
        
        let origin, x, y: CGFloat
        
        let clearButtonState = (clearButtonMode, hasText, iconToRightOfClear)
        let alignToButton: Bool
        switch clearButtonState {
            case (_, _, true):
                alignToButton = false
            // Clear button is visible
            case (.always, _, _), (.whileEditing, true, _), (.unlessEditing, false, _):
                alignToButton = true
            // Clear button is hidden
            case (.never, _, _), (.whileEditing, false, _), (.unlessEditing, true, _):
                fallthrough
            default:
                alignToButton = false
        }
        
        origin = calculateOrigin(alignToButton: alignToButton, bounds: bounds)
        x = offsetOrigin(origin, iconSize: iconSize)
        
        let yCenter = bounds.origin.y + bounds.height / 2
        y = yCenter - iconSize.height / 2 - iconMarginBottom
        return CGRect(x: x, y: y, width: iconSize.width, height: iconSize.height)
    }
    
    fileprivate func calculateOrigin(alignToButton: Bool, bounds: CGRect) -> CGFloat {
        let clearButtonRect = self.clearButtonRect(forBounds: bounds)
        switch (alignToButton, isLTRLanguage) {
            case (true, true):
                // Use left edge of clear button
                return clearButtonRect.origin.x
            case (true, false):
                // Use right edge of clear button
                return clearButtonRect.origin.x + clearButtonRect.width
            case (false, true):
                // Use right edge of bounds
                return bounds.origin.x + bounds.width
            case (false, false):
                // Use bounds origin
                return bounds.origin.x
        }
    }
    
    fileprivate func offsetOrigin(_ origin: CGFloat, iconSize: CGSize) -> CGFloat {
        if isLTRLanguage {
            return origin - iconSize.width - iconMarginRight
        } else {
            return origin + iconMarginRight
        }
    }
    
    /// Invoked by layoutIfNeeded automatically
    override open func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
    }
    
    fileprivate func updateFrame() {
        iconView.frame = iconRect(forBounds: self.bounds)
    }
    
    /// Invoked when the interface builder renders the control
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        iconView.image = UIImage(named: "Visa", in: Bundle(for: FloatingLabelTextFieldWithIcon.self), compatibleWith: nil)
    }
}
