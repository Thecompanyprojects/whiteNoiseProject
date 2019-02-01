//
//  ThemeImageManager.swift
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
//
import UIKit
@objcMembers
class ThemeImageManager: NSObject {
    let imageUrlKey = "imageUrl"
    let isDownloadedKey = "isDownloaded"
    
    
    static let shared = ThemeImageManager()
    
    
    private var localJsonModelArr = [ThemeImageModel]()
    
    
    /// 保存服务器配置的图片链接数组
    ///
    /// - imageUrls:
    func saveServerConfig(imageUrls:[String]){
        let arr = getLocalJson()
        
        var imageUrlsDic = [[String:String]]()
        
        for remote in imageUrls{
            var dic = [imageUrlKey:remote,isDownloadedKey:"0"]
            
            for i in arr{
                let url = i.imageUrl
                let isDownloaded = "\(i.isDownloaded)"
                if remote == url,isDownloaded == "1"{
                    dic[isDownloadedKey] = "1"
                }
            }
            imageUrlsDic.append(dic)
        }
        guard let dataJson = try? JSONSerialization.data(withJSONObject: imageUrlsDic, options: []) else{
            return
        }
        
        try? dataJson.write(to: URL(fileURLWithPath: self.path()))
    }
    
    
    /// 每次启动随机获取背景动图
    ///
    /// - Returns:
    func getRandom()->UIImage{
        let path = APDownloadPathHelper.downloadPath()!
        
        let arr = self.getDownloaded()
        if arr.count <= 0{
            return #imageLiteral(resourceName: "首页背景图-1")
        }
        
        let value : Int = Int(arc4random() % UInt32(arr.count))
        
        let url = arr[value].imageUrl
        
        let imageName = URL(string: url)!.lastPathComponent
        
        if let image = UIImage(contentsOfFile: path + "/" + imageName){
            return image
        }else{
            return #imageLiteral(resourceName: "首页背景图-1")
        }
        
    }
    
    
    /// 开始未完成的下载
    func beginDownloadImage(){
        let arr = getNotDownloaded()
        //TODO:下载
        for model in arr{
            let down = APSoundDownloadRequest.initWithURL(model.imageUrl)
            down?.delegate = self
            down?.startDownload()
        }
    }
    
    //MARK:- 获取已下载完成的图片数组
    fileprivate func getDownloaded()->[ThemeImageModel]{
        let arr = getLocalJson()
        var notArr = [ThemeImageModel]()
        for i in arr{
            if i.isDownloaded == 1{
                notArr.append(i)
            }
        }
        return notArr
    }
    //MARK:- 获取未下载的图片数组
    fileprivate func getNotDownloaded()->[ThemeImageModel]{
        let arr = getLocalJson()
        var notArr = [ThemeImageModel]()
        for i in arr{
            if i.isDownloaded == 0{
                notArr.append(i)
            }
        }
        return notArr
    }
    
    //MARK:- 获取本地存储的image数组
    fileprivate func getLocalJson()->[ThemeImageModel]{
        
        if localJsonModelArr.count > 0{
            return localJsonModelArr
        }
        
        let url =  URL(fileURLWithPath: self.path())
        
        guard let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let jsonDic = json as? [[String:Any]],
            let modelArr = NSArray.yy_modelArray(with: ThemeImageModel.self, json: jsonDic) as? [ThemeImageModel] else {
                return []
        }
        localJsonModelArr = modelArr
        return modelArr
    }
    
    //MARK:- 下载完成更新记录下载状态
    fileprivate func updateDownloadFinish(url:String){
        let arr = getLocalJson()
        for mode in arr{
            if mode.imageUrl == url{
                mode.isDownloaded = 1
            }
        }
        
        if arr.count == 0{
            printLog("数组为空了。不对")
        }
        if let dataJson = (arr as NSArray).yy_modelToJSONData(){
            
            try? dataJson.write(to: URL(fileURLWithPath: self.path()))
        }
    }
    
    fileprivate func path()->String{
        //    return "/Users/guoliancheng/Desktop/backImageArr.json"
        guard var pathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else{
            return ""
        }
        //拼接document
        let fileManage = FileManager.default
        
        pathString = pathString + "/XYTool"
        
        let exit = fileManage.fileExists(atPath: pathString)
        if exit == false{
            try? fileManage.createDirectory(atPath: pathString, withIntermediateDirectories: true, attributes: nil)
        }
        
        pathString = pathString + "/backImageArr.json"
        printLog(pathString)
        return pathString
    }
}
extension ThemeImageManager:APMusicDownloadDelegate{
    
    func requestDownloading(_ request: APSoundDownloadRequest!) {
        printLog("主题图片下载中\(request.progress)")
    }
    func requestDownloadPause(_ request: APSoundDownloadRequest!) {
        printLog("主题图片暂停下载\(request.url ?? "")")
    }
    func requestDownloadStart(_ request: APSoundDownloadRequest!) {
        printLog("主题图片开始下载\(request.url ?? "")")
    }
    func requestDownloadCancel(_ request: APSoundDownloadRequest!) {
        printLog("主题图片取消下载\(request.url ?? "")")
    }
    func requestDownloadFinish(_ request: APSoundDownloadRequest!) {
        printLog("主题图片下载完成\(request.url ?? "")")
        updateDownloadFinish(url: request.url)
    }
    func requestDownloadFaild(_ request: APSoundDownloadRequest!, aError error: Error!) {
        printLog("主题图片下载失败\(request.url ?? "")")
    }
}


class ThemeImageModel: NSObject {
    var imageUrl = "" //图片下载链接
    var isDownloaded : Int = 0 //未下载是0 ，已下载是1
}

