
//Falling down on me..

import UIKit

@IBDesignable
class ChordBase: UIView {
    
    override func drawRect(rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        
        let path = UIBezierPath()
        path.lineWidth = 1
        
        let margin:Float = 0.25
        
        let initialPoint:CGFloat = CGFloat(Float(width) * margin)
        let rightTopPoint:CGFloat = CGFloat(Float(width) * (1 - margin))

        path.moveToPoint(CGPoint(x: initialPoint, y: 0))
        path.addLineToPoint(CGPoint(x: rightTopPoint, y: 0))
        path.addLineToPoint(CGPoint(x: width, y: height))
        path.addLineToPoint(CGPoint(x: 0, y: height))
        path.addLineToPoint(CGPoint(x: initialPoint, y: 0))
        
        let color = UIColor(red: 1, green: 0, blue: 0, alpha: 0.3)
        
        //MARK: fix color and add gradient
        color.setFill()
        path.fill()
        
        let scale:Float = 1 / 12
        let topWidth = Float(rightTopPoint) - Float(initialPoint)
        let topLeft = Float(initialPoint) + Float(topWidth) * scale
        var topPoints = [CGFloat](count: 6, repeatedValue: 0)

        topPoints[0] = CGFloat(topLeft)
        for i in 1..<6 {
            topPoints[i] = CGFloat(Float(topPoints[i - 1]) + Float(topWidth * scale * 2))
        }
        
        var bottomPoints = [CGFloat](count: 6, repeatedValue: 0)
        bottomPoints[0] = CGFloat(Float(width) * scale)
        for i in 1..<6 {
            bottomPoints[i] = CGFloat(Float(bottomPoints[i - 1]) + Float(width) * scale * 2)
        }
        
        let innerpath = UIBezierPath()
        
        innerpath.lineWidth = 1
    
        
        UIColor.whiteColor().setStroke()
        
        //draw lines
        for i in 0..<6 {
            let startPoint:CGPoint = CGPoint(x: topPoints[i], y: 0)
            innerpath.moveToPoint(startPoint)
            innerpath.addLineToPoint(CGPoint(x: bottomPoints[i], y: height))
        }
        //this has to be set outside for loop to avoid spikes, IDK why  
        
        innerpath.stroke()
        
    }
    
    
}
