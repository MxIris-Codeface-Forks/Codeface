import AppKit
import UIToolz
import SwiftObserver

class SummaryView: NSView, Observer
{
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        layoutSubviews()
        
        folderPathLabel.alignment = .right
        
        observe(Store.shared, select: .didModifyData)
        {
            [weak self] in self?.storeDidModifyData()
        }
    }
    
    private func storeDidModifyData()
    {
        let store = Store.shared
        
        folderPathLabel.stringValue = "\(store.folderPath)"
        numbersLabel.stringValue = "\(store.numberOfLines) lines of code in \(store.analytics.count) Swift files"
    }
    
    private func layoutSubviews()
    {
        numbersLabel.constrainToParentExcludingRight(insetTop: 10,
                                                        insetLeft: 10,
                                                        insetBottom: 10)
        folderPathLabel.constrainToParentExcludingLeft(insetTop: 10,
                                                    insetBottom: 10,
                                                    insetRight: 10)
        folderPathLabel.constrain(toTheRightOf: numbersLabel, gap: 10)
        folderPathLabel.constrainWidth(to: numbersLabel)
    }
    
    required init?(coder decoder: NSCoder) { fatalError() }
    
    private lazy var numbersLabel = addForAutoLayout(Label())
    private lazy var folderPathLabel = addForAutoLayout(Label())
}
