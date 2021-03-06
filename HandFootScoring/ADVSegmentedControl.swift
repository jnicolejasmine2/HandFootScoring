//
//  ADVSegmentedControl.swift
//  Mega
//
//  Created by Tope Abayomi on 01/12/2014.
//  Copyright (c) 2014 App Design Vault. All rights reserved.
//


import UIKit

@IBDesignable class ADVSegmentedControl: UIControl {

    private var labels = [UILabel]()
    var thumbView = UIView()

    var items: [String] = ["Item 1", "Item 2", "Item 3", "Item 4"] {
        didSet {
            setupLabels()
        }
    }

    var selectedIndex : Int? {
        didSet {
            displayNewSelectedIndex()
        }
    }

    @IBInspectable var selectedLabelColor : UIColor = UIColor.whiteColor() {
        didSet {
            setSelectedColors()
        }
    }

    @IBInspectable var unselectedLabelColor : UIColor = Style.sharedInstance().gameSelectionControl()  {
        didSet {
            setSelectedColors()
        }
    }

    @IBInspectable var thumbColor : UIColor = Style.sharedInstance().gameSelectionControl() {
        didSet {
            setSelectedColors()
        }
    }

    @IBInspectable var borderColor : UIColor = Style.sharedInstance().gameSelectionControl() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }

    @IBInspectable var font : UIFont! = UIFont.systemFontOfSize(14) {
        didSet {
            setFont()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView(){

       // layer.cornerRadius = frame.height / 2
        layer.borderColor = Style.sharedInstance().gameSelectionControl().CGColor
        layer.borderWidth = 2

        backgroundColor = UIColor.clearColor()

        setupLabels()

        addIndividualItemConstraints(labels, mainView: self, padding: 0)

        insertSubview(thumbView, atIndex: 0)
    }


    // Changed font and selected colors to match my app
    func setupLabels(){

        for label in labels {
            label.removeFromSuperview()
        }

        labels.removeAll(keepCapacity: true)

        for index in 1...items.count {

            let label = UILabel(frame: CGRectMake(0, 0, 70, 40))
            label.text = items[index - 1]
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = .Center
            label.font = UIFont(name: "Helvetica Neue", size: 14)
            label.textColor = index == 1 ? selectedLabelColor : unselectedLabelColor
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 3
            self.addSubview(label)
            labels.append(label)
        }
        addIndividualItemConstraints(labels, mainView: self, padding: 0)
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        var selectFrame = self.bounds
        let newWidth = CGRectGetWidth(selectFrame) / CGFloat(items.count)
        selectFrame.size.width = newWidth
        thumbView.frame = selectFrame
        thumbView.backgroundColor = thumbColor

        displayNewSelectedIndex()

    }


    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {

        let location = touch.locationInView(self)

        var calculatedIndex : Int?
        for (index, item) in labels.enumerate() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }

        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActionsForControlEvents(.ValueChanged)
        }
        return false
    }


    func displayNewSelectedIndex(){
        for (_, item) in labels.enumerate() {
            item.textColor = unselectedLabelColor
        }

        if selectedIndex != nil {
            let label = labels[selectedIndex!]
            label.textColor = selectedLabelColor
            self.thumbView.frame = label.frame
        }

        // Removed Animation
    }


    func addIndividualItemConstraints(items: [UIView], mainView: UIView, padding: CGFloat) {

        _ = mainView.constraints

        for (index, button) in items.enumerate() {

            let topConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)

            let bottomConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)

            var rightConstraint : NSLayoutConstraint!

            if index == items.count - 1 {

                rightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -padding)
            }else{

                let nextButton = items[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: nextButton, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: -padding)
            }


            var leftConstraint : NSLayoutConstraint!

            if index == 0 {

                leftConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: padding)

            }else{

                let prevButton = items[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: prevButton, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: padding)

                let firstItem = items[0]

                let widthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: NSLayoutRelation.Equal, toItem: firstItem, attribute: .Width, multiplier: 1.0  , constant: 0)

                mainView.addConstraint(widthConstraint)
            }

            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }


    func setSelectedColors(){
        for item in labels {
            item.textColor = unselectedLabelColor
        }

        if labels.count > 0 {
            labels[0].textColor = selectedLabelColor
        }

            thumbView.backgroundColor = thumbColor

    }


    func setFont(){
        for item in labels {
            item.font = font
        }
    }

}
