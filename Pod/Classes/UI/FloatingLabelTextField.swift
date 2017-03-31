//  Copyright 2016 Skyscanner Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

import UIKit

/**
 * Floating label text field implementation.
 * Based on: https://github.com/Skyscanner/SkyFloatingLabelTextField
 */
@IBDesignable
open class FloatingLabelTextField: UITextField, UITextFieldDelegate {

    /// A Boolean value that determines if the language displayed is LTR. Default value set automatically from the application language settings.
    var isLTRLanguage = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
        didSet {
           updateTextAligment()
        }
    }

    fileprivate func updateTextAligment() {
        let alignment: NSTextAlignment
        if(isLTRLanguage) {
            alignment = .left
        } else {
            alignment = .right
        }
        textAlignment = alignment
        placeholderLabel.textAlignment = alignment
        hintLabel.textAlignment = alignment
    }

    // MARK: Animation timing

    /// Animation duration
    open var animationDuration: TimeInterval = 0.3

    // MARK: Colors

    /// A UIColor value that determines the text color of the editable text
    @IBInspectable
    override open var textColor: UIColor? {
        didSet {
            updateControl(false)
        }
    }

    /// A UIColor value that determines text color of the placeholder label
    @IBInspectable
    open var placeholderColor: UIColor = UIColor.gray.withAlphaComponent(0.7) {
        didSet {
            updatePlaceholderColor()
        }
    }
    
    /// A UIColor value that determines the text color of the placeholder label when editing
    @IBInspectable
    open var placeholderActiveColor: UIColor = UIColor.blue {
        didSet {
            updatePlaceholderColor()
        }
    }
    
    /// Text colour to be applied to the floating hint text. Default is [UIColor grayColor].
    @IBInspectable
    open var hintTextColor: UIColor = UIColor.gray {
        didSet {
            updateHintColor()
        }
    }

    /// A UIColor value that determines the color used for the hint label when the error message is not `nil`
    @IBInspectable
    open var errorColor: UIColor = UIColor.red {
        didSet {
            updateHintColor()
        }
    }

    // MARK: View components

    /// The internal `UILabel` that displays the placeholder, selected, deselected title.
    open var placeholderLabel: UILabel!
    /// The internal `UILabel` that displays the hint or the error message based on the current state.
    open var hintLabel: UILabel!

    // MARK: Properties

    /**
     Identifies whether the text object should hide the text being entered.
     */
    override open var isSecureTextEntry: Bool {
        set {
            super.isSecureTextEntry = newValue
            fixCaretPosition()
        }
        get {
            return super.isSecureTextEntry
        }
    }

    /// A String value for the error message to display.
    open var errorMessage: String? {
        didSet {
            updateControl(true)
        }
    }
    
    /// A Boolean value that determines whether the textfield is being edited or is selected.
    open var editingOrSelected: Bool {
        get {
            return super.isEditing || isSelected;
        }
    }

    /// A Boolean value that determines whether the receiver has an error message.
    open var hasErrorMessage: Bool {
        get {
            return errorMessage != nil && errorMessage != ""
        }
    }

    fileprivate var _renderingInInterfaceBuilder: Bool = false
    
    /// The text content of the textfield
    @IBInspectable
    override open var text: String? {
        didSet {
            updateControl(true)
        }
    }
    
    fileprivate var _placeholder: String = ""
    
    /// The String to display when the input field is empty.
    override open var placeholder: String? {
        get {
            return _placeholder
        }
        set {
            _placeholder = newValue ?? ""
            updatePlaceholder()
            super.placeholder = nil
        }
    }
    
    /// Text to be displayed in the floating hint label. Default is empty string.
    @IBInspectable
    open var hintText: String = "" {
        didSet {
            updateHint()
        }
    }
    
    /// Determines whether the field is selected. When selected, the placeholder floats above the textbox and becomes a title.
    override open var isSelected: Bool {
        didSet {
            updateControl(true)
        }
    }
    
    /// Font line height for main text
    open var textHeight: CGFloat {
        return self.font!.lineHeight
    }
    
    /// Font line height for title
    @IBInspectable
    open var titleSize: CGFloat = 12 {
        didSet {
            updatePlaceholderFont(placeholderLabel)
            updateControl()
        }
    }
    
    fileprivate var titleHeight: CGFloat = 0
    
    /// Font line height for hint/error
    @IBInspectable
    open var hintSize: CGFloat = 12 {
        didSet {
            updateHintFont(hintLabel)
            updateControl()
        }
    }
    
    fileprivate var hintHeight: CGFloat = 0
    
    fileprivate var hintFont: UIFont {
        return font!.withSize(hintSize)
    }
    
    /// Scale factor for title
    fileprivate var titleScale: CGFloat {
        return titleHeight / textHeight
    }
    
    override open var font: UIFont? {
        didSet {
            updatePlaceholderFont(placeholderLabel)
            updateHintFont(hintLabel)
            updateControl()
        }
    }
    
    /// Padding between title and text. Default iz 0.
    @IBInspectable
    open var titlePadding: CGFloat = 0 {
        didSet {
            updateControl()
        }
    }
    
    /// Padding between text and hint. Default iz 0.
    @IBInspectable
    open var hintPadding: CGFloat = 0 {
        didSet {
            updateControl()
        }
    }

    // MARK: - Initializers

    /**
    Initializes the control
    - parameter frame the frame of the control
    */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        init_FloatingLabelTextField()
    }

    /**
     Initialzies the control by deserializing it
     - parameter coder the object to deserialize the control from
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init_FloatingLabelTextField()
    }

    fileprivate final func init_FloatingLabelTextField() {
        clipsToBounds = false
        borderStyle = .none
        createPlaceholderLabel()
        createHintLabel()
        updateColors()
        addObservers()
        updateTextAligment()
        delegate = self
    }
    
    fileprivate func addObservers() {
        addTarget(self, action: #selector(FloatingLabelTextField.editingChanged), for: .editingChanged)
        addTarget(self, action: #selector(FloatingLabelTextField.editingBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(FloatingLabelTextField.editingEnd), for: .editingDidEnd)
    }

    /**
     Invoked when the editing state of the textfield changes. Override to respond to this change.
     */
    open func editingChanged() {
        updateControl(true)
    }
    
    open func editingBegin() {
        updateControl(true)
    }
    
    open func editingEnd() {
        updateControl(true)
    }

    // MARK: create components

    fileprivate func createPlaceholderLabel() {
        let placeholderLabel = UILabel()
        placeholderLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        updatePlaceholderFont(placeholderLabel)
        addSubview(placeholderLabel)
        self.placeholderLabel = placeholderLabel
    }
    
    fileprivate func createHintLabel() {
        let hintLabel = UILabel()
        hintLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        updateHintFont(hintLabel)
        addSubview(hintLabel)
        self.hintLabel = hintLabel
    }

    // MARK: Responder handling

    /**
     Attempt the control to become the first responder
     - returns: True when successfull becoming the first responder
    */
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self)
        return super.becomeFirstResponder()
    }

    // MARK: - View updates
    
    fileprivate func updatePlaceholderFont(_ label: UILabel) {
        label.font = font
        titleHeight = font!.withSize(titleSize).lineHeight
    }
    
    fileprivate func updateHintFont(_ label: UILabel) {
        let font = hintFont
        label.font = font
        hintHeight = font.lineHeight
    }

    fileprivate func updateControl(_ animated: Bool = false) {
        updateColors()
        updatePlaceholder(animated)
        updateHint(animated)
    }

    // MARK: - Color updates

    /// Update the colors for the control. Override to customize colors.
    open func updateColors() {
        updatePlaceholderColor()
        updateHintColor()
    }

    fileprivate func updatePlaceholderColor() {
        let color: UIColor
        if editingOrSelected {
            color = placeholderActiveColor
        } else {
            color = placeholderColor
        }
        placeholderLabel.textColor = color
    }

    fileprivate func updateHintColor() {
        let color: UIColor
        if hasErrorMessage {
            color = errorColor
        } else {
            color = hintTextColor
        }
        hintLabel.textColor = color
    }

    // MARK: - Title handling

    fileprivate func updatePlaceholder(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
        placeholderLabel.text = placeholder
        
        let visible = self.isTitleVisible()
        let transform: CGAffineTransform
        let frame: CGRect
        
        if visible {
            transform = CGAffineTransform(scaleX: titleScale, y: titleScale)
            frame = titleRect(forBounds: self.bounds)
        } else {
            transform = CGAffineTransform.identity
            frame = placeholderRect(forBounds: self.bounds)
        }
        
        let updateBlock = { () -> Void in
            self.placeholderLabel.transform = transform
            self.placeholderLabel.frame = frame
        }
        
        if animated {
            let animationOptions: UIViewAnimationOptions = [.curveEaseOut, .beginFromCurrentState, .transitionCrossDissolve]
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: updateBlock, completion: completion)
        } else {
            updateBlock()
            completion?(true)
        }
    }
    
    fileprivate func updateHint(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
        let text: String?
        let alpha: CGFloat
        if hasErrorMessage {
            text = errorMessage
            alpha = 1.0
        } else {
            text = hintText
            alpha = text == nil || text == "" ? 0.0 : 1.0
        }
        hintLabel.text = text
        let updateBlock = { () -> Void in
            self.hintLabel.alpha = alpha
        }
        
        if animated {
            let animationOptions: UIViewAnimationOptions = .beginFromCurrentState
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: updateBlock, completion: completion)
        } else {
            updateBlock()
            completion?(true)
        }
    }

    /**
     Returns whether the title is being displayed on the control.
     - returns: True if the title is displayed on the control, false otherwise.
     */
    open func isTitleVisible() -> Bool {
        return self.hasText || self.editingOrSelected
    }

    // MARK: - UITextField text/placeholder positioning overrides

    /**
    Calculate the rectangle for the textfield when it is not being edited
    - parameter bounds: The current bounds of the field
    - returns: The rectangle that the textfield should render in
    */
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        rect.origin.y = titleHeight + titlePadding
        rect.size.height -= CGFloat(titleHeight + hintHeight + titlePadding + hintPadding)
        return rect
    }

    /**
     Calculate the rectangle for the textfield when it is being edited
     - parameter bounds: The current bounds of the field
     - returns: The rectangle that the textfield should render in
     */
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        rect.origin.y = titleHeight + titlePadding
        rect.size.height -= CGFloat(titleHeight + hintHeight + titlePadding + hintPadding)
        return rect
    }

    /**
     Calculate the rectangle for the placeholder
     - parameter bounds: The current bounds of the placeholder
     - returns: The rectangle that the placeholder should render in
     */
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        rect.origin.y = titleHeight + titlePadding
        rect.size.height -= CGFloat(titleHeight + hintHeight + titlePadding + hintPadding)
        return rect
    }

    // MARK: - Positioning Overrides

    /**
    Calculate the bounds for the title label. Override to create a custom size title field.
    - parameter bounds: The current bounds of the field
    - returns: The rectangle that the title label should render in
    */
    open func titleRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: bounds.size.width, height: titleHeight)
    }
    
    /**
     Calculate the bounds for the hint label. Override to create a custom size hint field.
     - parameter bounds: The current bounds of the field
     - returns: The rectangle that the title label should render in
     */
    open func hintRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: bounds.size.height - hintHeight, width: bounds.size.width, height: hintHeight)
    }


    // MARK: - Layout

    /// Invoked when the interface builder renders the control
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        borderStyle = .none
        
        isSelected = true
        _renderingInInterfaceBuilder = true
        updateControl(false)
        invalidateIntrinsicContentSize()
    }

    /// Invoked by layoutIfNeeded automatically
    override open func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.frame = isTitleVisible() ? titleRect(forBounds: self.bounds) : placeholderRect(forBounds: self.bounds)
        hintLabel.frame = hintRect(forBounds: self.bounds)
    }

    /**
     Calculate the content size for auto layout

     - returns: the content size to be used for auto layout
     */
    override open var intrinsicContentSize : CGSize {
        let totalHeight = titleHeight + textHeight + hintHeight + titlePadding + hintPadding
        return CGSize(width: self.bounds.size.width, height: totalHeight)
    }
}

// MARK: - UITextFieldDelegate
extension FloatingLabelTextField {
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
}
