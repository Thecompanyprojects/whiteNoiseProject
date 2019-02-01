//
//  MusicPlayerCircleView.swift
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
@objc protocol MusicPlayerCircleViewDelegate:NSObjectProtocol {
    
    /// 点击了播放按钮
    ///
    /// - Parameter isPlay: 是播放还是暂停
    func musicPlayerViewClikcPlayBtn(isPlay:Bool)
    /// 点击了CD 重启下载任务
    func musicPlayerViewClikcRestartTask()
    /// 点击了小音效按钮
    func musicPlayerViewClikcSoundsBtn()
    /// 点击了另存为按钮
    func musicPlayerViewClikcLikeBtn()
}

@objcMembers
class MusicPlayerCircleView: UIView {
    
    typealias ClickPlay = (_ isPlay:Bool)->()
    
    weak var delegate:MusicPlayerCircleViewDelegate?
    
    ///收藏按钮的水平方向约束，做偏移用
    @IBOutlet weak var likeBtnConstraint: NSLayoutConstraint!
    ///播放按钮的水平方向约束，做偏移用
    @IBOutlet weak var playBtnConstraint: NSLayoutConstraint!
    ///播放CD的顶部约束
    @IBOutlet weak var circleTopConstraint: NSLayoutConstraint!
    ///选中的倒计时时间
    fileprivate var selectTime = 30
    
    @IBOutlet weak var backImageMaskView: UIView!
    
    @IBOutlet weak var likeBtn: UIButton!
    ///播放按钮
    @IBOutlet weak var playBtn: UIButton!
    ///背景图片
    @IBOutlet weak var backImageView: UIImageView!
    ///CD
    @IBOutlet weak var circleView: UIView!
    ///CD线条边
    @IBOutlet weak var circle: UIImageView!
    ///CD尾巴
    @IBOutlet weak var tail: UIImageView!
    ///进度label
    @IBOutlet weak var progessLabel: UILabel!
    
    var progess : Float = 0{
        didSet{
            self.progessLabel.text = "\(Int(progess * 100))%"
        }
    }
    
    ///下载完成后控制器通知view改变
    var isDownLoadFinish = false{
        didSet{
            if !isDownLoadFinish{
                self.progessLabel.text = "Network timeout"
                return
            }
                self.progessLabel.isHidden = true
                self.downloadTip.isHidden = true
                self.countDown.isHidden = false
                self.play()
                playBtn.isEnabled = true
        }
    }
    
    /// 下载tip
    @IBOutlet weak var downloadTip: UILabel!
    /// 倒计时时间
    @IBOutlet weak var countDown: UILabel!
    
    //MARK:- CD有个按钮，处理倒计时响应，下载暂停响应
    @IBAction func clickCDBtn(_ sender: UIButton) {
        self.delegate?.musicPlayerViewClikcRestartTask()
        
        let v = LCCountDownPicker(scrollToSource: self.selectTime) { [weak self](selectTime) in
            self?.selectTime = selectTime
            APAudioPlayerTools.shared().configCountDown(selectTime * 60)
            if self?.playBtn.isSelected == false{
                APAudioPlayerTools.shared()?.stopTimer()
            }else{
                APAudioPlayerTools.shared()?.beginTimer()
            }
            
        }
        
        let img = self.backImageView.image
        v.image = img
        v.showIn(view: self)
    }
 
     func play(){
            playUI()
            APAudioPlayerTools.shared().configCountDown(30*60)
            APAudioPlayerTools.shared()?.beginTimer()
        if playModel?.isDownloading == false && playModel?.mp3FileName != nil{//不下载的时候再去下载图片
            ThemeImageManager.shared.beginDownloadImage()
        }
    }
    
    ///点击了音效按钮
    func clickSoundIcon(sender: UITapGestureRecognizer){
        self.delegate?.musicPlayerViewClikcSoundsBtn()
    }
    ///点击收藏按钮（自定义界面用到）
    @IBAction func clickLikeBtn(_ sender: UIButton) {
        self.delegate?.musicPlayerViewClikcLikeBtn()
    }
    
    var isAnimateing : Bool = false //动画是否进行中
    ///播放按钮点击事件
    @IBAction func clickPlayBtn(_ sender: UIButton) {
        if isAnimateing == true{
            printLog("动画进行中，不响应本次点击")
            return
        }
        isAnimateing = true
        
        
        
        let bool = sender.isSelected
    
        let v = UIImageView()
        v.frame = sender.frame
        self.addSubview(v)
        
        //动画执行完后 isSelected = true 是播放中
        v.image = #imageLiteral(resourceName: "zantingzhong")

        if !bool{
            sender.setImage(#imageLiteral(resourceName: "bofangzhong"), for: UIControl.State.normal)
            sender.setImage(#imageLiteral(resourceName: "bofangzhong"), for: UIControl.State.selected)
            sender.isSelected = true
            
            
            v.layer.transform = CATransform3DMakeScale(1, 1, 1)
            UIView.animate(withDuration: 0.4, animations: {
                // 按照比例scalex=0.001,y=0.001进行缩小
                v.layer.transform = CATransform3DMakeScale(0.001, 0.001, 1);
            }) { (isSuccess) in
                v.removeFromSuperview()
                self.delegate?.musicPlayerViewClikcPlayBtn(isPlay: sender.isSelected)
                self.isAnimateing = false
            }
        }else{
            v.layer.transform = CATransform3DMakeScale(0.001, 0.001, 1);
            UIView.animate(withDuration: 0.4, animations: {
                // 按照比例scalex=0.001,y=0.001进行缩小
                v.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }) { (isSuccess) in
                sender.setImage(#imageLiteral(resourceName: "zantingzhong"), for: UIControl.State.selected)
                sender.setImage(#imageLiteral(resourceName: "zantingzhong"), for: UIControl.State.normal)
                sender.isSelected = false
                v.removeFromSuperview()
                self.delegate?.musicPlayerViewClikcPlayBtn(isPlay: sender.isSelected)
                self.isAnimateing = false
            }
        }
    }
    func playUI(){
        if !playBtn.isSelected{
            clickPlayBtn(playBtn)
        }
    }
    
    func stopUI(){
        if playBtn.isSelected{
            clickPlayBtn(playBtn)
        }
    }
    
    override func didMoveToSuperview() {
        if (superview != nil) {
            APAudioPlayerTools.shared().delegate = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
//                self.play()
            }
        }
    }
    
    //TODO: 考虑用协议兼容两中播放模型
    //单个播放模型
    
    var playModel : MusicInfo?{
        didSet{
            guard playModel != nil else {
                return
            }
            //背景图
            if (playModel!.backGroundImageUrl.isEmpty){
                
            }else if playModel!.backGroundImageUrl.contains("http"){
                
               if let url = URL(string: playModel!.backGroundImageUrl){
                    backImageView.sd_setImage(with: url,
                                              placeholderImage: #imageLiteral(resourceName: "首页背景图模糊"),
                                              options: [],
                                              completed: nil)
                }
                
            }else{
                let image = UIImage(named: playModel!.backGroundImageUrl)
                backImageView.image = image
            }
            
            backImageMaskView.backgroundColor = UIColor(hexString: playModel!.argb)
            
            //下载和没下载
            if (playModel!.mp3FileName == nil) ||
                playModel!.mp3FileName.isEmpty{
                downloadTip.isHidden = false
                progessLabel.isHidden = false
                playBtn.isEnabled = false
            }else{
                countDown.isHidden = false
                playBtn.isEnabled = true
            }
        }
    }
    
    //自定义音效 播放模型
    var APCustomModel : APCustomModel?{
        didSet{
            guard APCustomModel != nil else {
                return
            }
            //背景图
            if (APCustomModel!.icon_bg_name == nil || APCustomModel!.icon_bg_name.isEmpty){
                
            }else if APCustomModel!.icon_bg_name.contains("http"){
                let url = URL(string: APCustomModel!.icon_bg_name)
                backImageView.sd_setImage(with: url!,
                                          placeholderImage: #imageLiteral(resourceName: "首页背景图模糊"),
                                          options: [],
                                          completed: nil)
            }else{
                let image = UIImage(named: APCustomModel!.icon_bg_name)
                backImageView.image = image
            }
            collection.mas_remakeConstraints { (make) in
                
                var width = APCustomModel!.sounds.count * 40 + (APCustomModel!.sounds.count - 1)  * 20
                if APCustomModel!.sounds.count == 0{width+=20}
                make?.width.mas_equalTo()(width)
                make?.height.mas_equalTo()(40)
                make?.centerX.mas_equalTo()(self)
                make?.top.mas_equalTo()(self.circleView.mas_bottom)?.offset()(20)
            }
            likeBtn.isHidden = false
            countDown.isHidden = false
            playBtnConstraint.constant = 60+7.5
            likeBtnConstraint.constant = -(60+7.5)
//            needsUpdateConstraints()
//            updateConstraintsIfNeeded()
            layoutIfNeeded()
            backImageMaskView.backgroundColor = UIColor(white: 0, alpha: 0.4)
            self.collection.reloadData()
        }
    }
    
    
    deinit {
        printLog("我已释放")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        countDown.center = circleView.center
    }

    
    func endAnimation(){
        circleView.layer.removeAnimation(forKey: "z")
        tail.layer.removeAnimation(forKey: "breathe")
    }
    
    func beginAnimation(){
        let basicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        
        basicAnimation.fromValue = 0
        basicAnimation.toValue = Double.pi * 2
        basicAnimation.repeatCount = MAXFLOAT
        basicAnimation.duration = 7
        //若要将removedOnCompletion设置为NO,fillMode必须设置为kCAFillModeForwards
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        //若要将removedOnCompletion设置为NO表示动画结束后图形不会回到初始状态
        
        basicAnimation.isRemovedOnCompletion = false
        circleView.layer.add(basicAnimation, forKey: "z")
        tailBreathe()
    }
    
    func tailBreathe(){
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0.6 //这是透明度。
        animation.autoreverses = true
        animation.duration = 3
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards;
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        tail.layer.add(animation, forKey: "breathe")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        countDown.font = preferredFont(size: 40)
        self.countDown.sizeToFit()
        
        addSubview(collection)
        collection.mas_makeConstraints { (make) in
            make?.width.mas_equalTo()(100)
            make?.height.mas_equalTo()(40)
            make?.centerX.mas_equalTo()(self)
            make?.top.mas_equalTo()(self.circleView.mas_bottom)?.offset()(20)
        }
        guard #available(iOS 11.0, *) else{
            circleTopConstraint.constant = (circleTopConstraint.constant + 64)
            return
        }
    }
    
    private lazy var collection: UICollectionView = {
        let v = UICollectionView(frame: CGRect.zero, collectionViewLayout: MusicPlayerSoundLayout())
        v.register(MusicPlayerCircleViewCell.self, forCellWithReuseIdentifier: "MusicPlayerCircleViewCell")
        let pan = UITapGestureRecognizer(target: self, action: #selector(clickSoundIcon(sender:)))
        v.addGestureRecognizer(pan)
        v.isUserInteractionEnabled = true
        v.backgroundColor = .clear
        v.dataSource = self
        return v
    }()
    
    //做动画会有动画差，动画没完之前不执行相反的动画效果
    private lazy var btnIsSelected = false
}

extension MusicPlayerCircleView:APAudioPlayerToolsDelegate{
    func playCurrentProgress(_ second: Int, withTotalCount totalSecond: Int) {
        
        //当前播放时间
//        var dict = MPNowPlayingInfoCenter.default().nowPlayingInfo
//
//        dict?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: second)
//
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = dict
        
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];
//        [dict setObject:[NSNumber numberWithDouble:self.player.currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经过时间
//        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        
        
        printLog("\(second)---\(totalSecond)")
        let s = String(format: "%02d", (totalSecond - second) % 60)
        let m = String(format: "%02d", (totalSecond - second) / 60)
        let time = "\(m) : \(s)"
        if (totalSecond - second) <= 0{
            stopUI()//倒计时结束后暂停界面
        }
        self.countDown.text = time
        self.countDown.sizeToFit()
    }
}

extension MusicPlayerCircleView:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if APCustomModel != nil{
            return APCustomModel!.sounds.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MusicPlayerCircleViewCell", for: indexPath) as! MusicPlayerCircleViewCell
        
        cell.imageUrl = (APCustomModel!.sounds[indexPath.item] as! APSoundModel).image_select
        return cell
    }
}

class MusicPlayerCircleViewCell : UICollectionViewCell{
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageIcon)
        imageIcon.mas_remakeConstraints { (make) in
            make?.edges.mas_equalTo()(self)
        }
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var imageUrl = ""{
        didSet{
            printLog(imageUrl)
            if (imageUrl.isEmpty){
                
            }else if imageUrl.contains("http"),
                  let url = URL(string: imageUrl){
                
                imageIcon.sd_setImage(with: url) { (image, error, type, url) in
                    if image != nil{
                        self.imageIcon.image = image?.withTintColor(UIColor.white)
                    }
                }
            }else{
                let image = UIImage(named: imageUrl)
                imageIcon.image = image
            }
        }
    }
    private lazy  var imageIcon : UIImageView = {
        let v = UIImageView()
        v.layer.cornerRadius = self.bounds.width/2
        v.layer.masksToBounds = true
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()
    
}



