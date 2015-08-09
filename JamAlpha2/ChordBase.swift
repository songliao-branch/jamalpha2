
//Falling down on me..

import UIKit

@IBDesignable
class ChordBase: UIView {
    
    var cornerRadius:CGFloat = 6
    
    
    override func drawRect(rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        
        let path = UIBezierPath()
        path.lineWidth = 1
        
        let margin:Float = 0.25
        
        let initialPoint:CGFloat = CGFloat(Float(width) * margin)
        let rightTopPoint:CGFloat = CGFloat(Float(width) * (1 - margin))
        
        
        
        
        //calculate radius and position for the four corners
        let tempYposition = cornerRadius * height / ( sqrt( pow(height,2) + pow(width - rightTopPoint, 2)))
        let tempXposition =  cornerRadius * ( width - rightTopPoint ) / ( sqrt( pow(height,2) + pow(width - rightTopPoint, 2)))
        
        let lineTop = sqrt(pow(tempYposition,2) + pow(tempXposition + cornerRadius, 2))
        let radiusTop = ((lineTop/2)/(sqrt(pow(cornerRadius,2)-pow(lineTop/2,2)))) * cornerRadius
        
        let lineBot = sqrt(pow(tempYposition,2)+pow(cornerRadius-tempXposition,2))
        let radiusBot = ((lineBot/2)/(sqrt(pow(cornerRadius,2)-pow(lineBot/2,2)))) * cornerRadius
        
        
        path.moveToPoint(CGPoint(x: initialPoint + cornerRadius , y: 0))
        path.addLineToPoint(CGPoint(x: rightTopPoint - cornerRadius, y: 0))
        
        
        path.addCurveToPoint(CGPoint(x: tempXposition + rightTopPoint, y: tempYposition), controlPoint1: CGPoint(x: rightTopPoint-cornerRadius+(cornerRadius+tempXposition)/2, y: radiusTop - sqrt(pow(radiusTop,2) - pow((cornerRadius+tempXposition)/2 ,2 ))), controlPoint2: CGPoint(x:  rightTopPoint - cornerRadius + sqrt(pow(radiusTop,2) - pow(radiusTop-tempYposition/2 ,2 )), y: tempYposition/2))
        
        
        path.addLineToPoint(CGPoint(x: width - tempXposition, y: height - tempYposition))
        
        
        path.addCurveToPoint(CGPoint(x: width - cornerRadius, y: height), controlPoint1: CGPoint(x: width-cornerRadius/2, y: height-(radiusBot - sqrt(pow(radiusBot,2) - pow((cornerRadius)/2 ,2 )))), controlPoint2: CGPoint(x:  width - cornerRadius + sqrt(pow(radiusBot,2) - pow(radiusBot-tempYposition/2 ,2 )), y: height-tempYposition/2))
        
        path.addLineToPoint(CGPoint(x: cornerRadius, y: height))
        
        path.addCurveToPoint(CGPoint(x: tempXposition, y: height-tempYposition), controlPoint1: CGPoint(x: cornerRadius/2, y: height-(radiusBot - sqrt(pow(radiusBot,2) - pow((cornerRadius)/2 ,2 )))), controlPoint2: CGPoint(x: cornerRadius - sqrt(pow(radiusBot,2) - pow(radiusBot-tempYposition/2 ,2 )), y: height-tempYposition/2))
        
        path.addLineToPoint(CGPoint(x: initialPoint-tempXposition, y: tempYposition))
        
        path.addCurveToPoint(CGPoint(x: initialPoint+cornerRadius, y: 0), controlPoint1: CGPoint(x: initialPoint+cornerRadius-(cornerRadius+tempXposition)/2, y: radiusTop - sqrt(pow(radiusTop,2) - pow((cornerRadius+tempXposition)/2 ,2 ))), controlPoint2: CGPoint(x:  initialPoint + cornerRadius - sqrt(pow(radiusTop,2) - pow(radiusTop-tempYposition/2 ,2 )), y: tempYposition/2))
        
        
        let whiteColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        //MARK: fix color and add gradient
        whiteColor.setFill()
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
