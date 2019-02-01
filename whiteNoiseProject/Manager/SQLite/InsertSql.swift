
//跟新后台数据库的语句
import Foundation


class InsertSql {
    
    
    func bianli(){
        
        guard let path = Bundle.main.path(forResource: "musicList.json", ofType: nil) else {
            print("path有问题")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        let data = try! Data(contentsOf: url)
        
        
        guard let classArr = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String:String]] else {
            print("不是大字典")
            return
        }
        
        
        var jsonArr = [[String:String]]()
        for dic in classArr!{
            let dic = insertRowArr(dic: dic)
            jsonArr.append(dic)
        }
        print("\(jsonArr)")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonArr, options: [])  else{
            return
        }
        
        let bundleUrl =  URL(fileURLWithPath: "/Users/guoliancheng/Desktop/musicList.json")
        try? jsonData.write(to: bundleUrl)
    }
    
    
    
    func insertRowArr(dic:[String:String])->[String:String]{
        
        let id = dic["id"]!
        let flag = dic["flag"]!
        let name_zh = dic["name_zh"]!
        let name_en = dic["name_en"]!
        var download_url = dic["download_url"]!
        
        
        var image_url = dic["image_url"]!
        var background_img_url = dic["background_img_url"]!
        
        
        image_url = insertUrl(image_url.encoding() + ".png")
        background_img_url =  insertUrl(background_img_url.encoding() + ".png")
        download_url = insertUrl(download_url + ".mp3")
        
        
        
        let arr = [id,"0",flag,"0","4.99","",
                   name_zh,name_en,
                   image_url,
                   download_url,
                   "content",
                   background_img_url]
        
        insertRow(row: arr)
        
        var jsonDic = dic
        jsonDic["price"] = "4.99"
        jsonDic["image_url"] = image_url
        jsonDic["background_img_url"] = background_img_url
        jsonDic["download_url"] = download_url
        
        return jsonDic
    }
    
    
    
    
    func insertRow(row:[String]){
        var sql = ""
        
        for i in 0..<row.count{
            if i == row.count-1{
                sql = sql + "'\(row[i])'"
            }else{
                sql = sql + "'\(row[i])'," + "\n"
            }
        }
        
        sql = "(" + sql + "),"
        print("\n\(sql)\n")
    }
    
    
    func insertUrl(_ str:String)->String{
        return "http://inoiseonea.com/cutecamera_images/whitenoise/\(str)"
    }
}

extension String{
    func encoding()->String{
        let c = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return c
    }
}
