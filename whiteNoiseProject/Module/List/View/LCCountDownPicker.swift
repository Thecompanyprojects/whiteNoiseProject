//
//  LCCountDownPicker.swift
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
import UIKit

class LCCountDownPicker:UIView{
    typealias callBack = (_ selectRow:Int)->()
    var image : UIImage?{
        didSet{
            
            self.datePickerBack.image = image!
            //            gaussianBlur(image: image!) { (image) in
            //            }
            
            //            let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
            //            let effectView = UIVisualEffectView(effect: effect)
            //            effectView.frame = self.frame
            //            datePickerBack.addSubview(effectView)
        }
    }
    
    func showIn(view:UIView){
        self.alpha = 0
        view.addSubview(self)
        UIView.animate(withDuration: 0.35) {
            self.alpha = 1
        }
    }
    
    //MARK:- 点击了确定或者取消
    @objc func clickCancelOrConfirm(btn:UIButton){
        if btn.tag == 1{
            if scrollToSource == 0,sourceArray.count > 0{
                scrollToSource = sourceArray[0]
            }
            selectBlock?(scrollToSource)
        }
        
        UIView.animate(withDuration: 0.35, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    /**
     默认滚动到当前时间
     */
    convenience init(scrollToSource:Int,completeBlock:@escaping callBack){
        self.init()
        
        self.scrollToSource = scrollToSource
        selectBlock = completeBlock
        self.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.layoutIfNeeded()
        
        addSubview(datePickerBack)
        addSubview(backBtn)
        addSubview(datePicker)
        addSubview(selectBtn)
        
        datePickerBack.frame = self.frame
        backBtn.frame = self.frame
        
        
        datePicker.mas_makeConstraints { (make) in
            make?.width.mas_equalTo()(170)
            make?.centerX.mas_equalTo()(self)
            let top = 110 //- (UIDevice.current.isX() ? 88 : 64)
            make?.top.mas_equalTo()(self)?.offset()(CGFloat(top))
            make?.height.mas_equalTo()(300)
        }
        
        selectBtn.mas_makeConstraints { (make) in
            make?.centerX.mas_equalTo()(self)
            make?.bottom.mas_equalTo()(self)?.offset()(-90)
        }
        
        
        
        defaultConfig()
    }
    
    
    func defaultConfig() {
        sourceArray.removeAll()
        
        let arr = [10,15,20,25,30,35,40,45,50,55,60]
        
        sourceArray = arr
        //        printLog(country)
        
        //设置数据
        if let index = sourceArray.index(of: scrollToSource){
            getNowRow(row: index, animated: true)
        }
    }
    
    deinit {
        //        printLog("我已释放")
    }
    
    //MARK:- lazy
    /**
     *  滚轮日期颜色(默认黑色)
     */
    var datePickerColor = UIColor.white
    
    fileprivate var needAnimate = true
    
    //日期存储数组
    fileprivate var sourceArray =  [Int]()
    
    //记录位置
    fileprivate var sourceIndex = 0
    
    
    fileprivate lazy var selectBtn : UIButton = {
        let v = UIButton()
        v.tag = 1
        v.setImage(#imageLiteral(resourceName: "queding"), for: UIControl.State.normal)
        v.addTarget(self, action: #selector(clickCancelOrConfirm(btn:)), for: UIControl.Event.touchUpInside)
        return v
    }()
    
    fileprivate lazy var datePicker : UIPickerView = {
        let v = UIPickerView()
        v.showsSelectionIndicator = true
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    fileprivate lazy var backBtn : UIButton = {
        let v = UIButton()
        v.alpha = 0.6
        v.backgroundColor = UIColor.black
        v.adjustsImageWhenHighlighted = false
        v.addTarget(self, action: #selector(clickCancelOrConfirm(btn:)), for:UIControl.Event.touchUpInside)
        return v
    }()
    
    fileprivate lazy var datePickerBack : UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        return v
    }()
    
    fileprivate var scrollToSource : Int = 0
    fileprivate var selectBlock : callBack?
}



//MARK:- UIPickerViewDataSource
extension LCCountDownPicker:UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sourceArray.count
    }
}

extension LCCountDownPicker:UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 70
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView{
        
        //设置分割线的颜色
        for singleLine in pickerView.subviews{
            if (singleLine.frame.size.height < 1){
                singleLine.backgroundColor = UIColor.white
                singleLine.alpha = 1
            }
        }
        
        let customLabel = UILabel.init()
        
        let title = "\(sourceArray[row])" + Bundle.main.localizedString(forKey: "minutes", value: "", table: nil)
        
        customLabel.textAlignment = .center
        customLabel.font = preferredFont(size: 31)
        customLabel.text = title
        customLabel.textColor = datePickerColor
        return customLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        sourceIndex = row
        
        pickerView.reloadAllComponents()
        
        scrollToSource = sourceArray[row]
        //选中回调放到确定中
        selectBtnAnimate()
    }
    
    
    
    //滚动到指定的时间位置
    func getNowRow(row:Int,animated:Bool){
        
        datePicker.reloadAllComponents()
        datePicker.selectRow(row, inComponent: 0, animated: animated)
    }
    //MARK:- 第一次选择时间后 确定按钮做个动画
    func selectBtnAnimate(){
        if !needAnimate {return}
        needAnimate = false
        
        let v = UIImageView()
        v.frame = selectBtn.frame
        self.addSubview(v)
        //isSelected = true 是暂停中
        
        v.image = #imageLiteral(resourceName: "xuanhao queren icon")
        
        v.layer.transform = CATransform3DMakeScale(0.001, 0.001, 1);
        selectBtn.setImage(#imageLiteral(resourceName: "xuanhao queren icon"), for:UIControl.State.selected)
        UIView.animate(withDuration: 0.4, animations: {
            // 按照比例scalex=0.001,y=0.001进行缩小
            v.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }) { (isSuccess) in
            self.selectBtn.setImage(#imageLiteral(resourceName: "xuanhao queren icon"), for:UIControl.State.normal)
            v.removeFromSuperview()
        }
    }
}


func printLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line){
    //    #if DEBUG
    
    if let fileName = URL(string: file)?.lastPathComponent{
        print("\(fileName) \(method)[\(line)]: \(message)")
    }else{
        print("\(method)[\(line)]: \(message)")
    }
    //    #endif
}

func gaussianBlur(image:UIImage,callBack:@escaping ((_ image:UIImage)->())){
    DispatchQueue.global().async {
        let inputImg = CIImage(cgImage: image.cgImage!)
        let filter = CIFilter(name: "CIGaussianBlur")
        
        filter?.setValue(inputImg, forKey: kCIInputImageKey)
        filter?.setValue(2, forKey: "inputRadius")
        let outPutImg = filter!.value(forKey: kCIOutputImageKey)
        let context = CIContext(options: nil)
        
        let cgImage = context.createCGImage(outPutImg as! CIImage, from: inputImg.extent)
        
        let resultImg = UIImage(cgImage: cgImage!)
        //    CGImageRelease(cgImage!)
        if #available(iOS 10.0, *) {
            context.clearCaches()
            
        } else {
            // Fallback on earlier versions
        }
        DispatchQueue.main.async {
            callBack(resultImg)
        }
        //        return
    }
    
}


//CIImage * inputImg = [[CIImage alloc] initWithImage:image];
////创建滤镜
//CIFilter * filter = [CIFilter filterWithName:@""];
////设置滤镜输入图片
//[filter setValue:inputImg forKey:kCIInputImageKey];
////设置模糊效果大小
//[filter setValue:@3 forKey:@"inputRadius"];
////获取滤镜输出图片
//CIImage * outputImg = [filter valueForKey:kCIOutputImageKey];
////通过CIImage创建CGImage  大小如果使用 outputImg.extent结果会有白边
//CGImageRef cgImage = [context createCGImage:outputImg fromRect:inputImg.extent];
////通过CGImage创建UIImage
//UIImage * resultImg = [UIImage imageWithCGImage:cgImage];
