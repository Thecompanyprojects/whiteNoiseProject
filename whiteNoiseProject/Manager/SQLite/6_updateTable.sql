
--如果表存在，就删掉
DROP TABLE IF EXISTS MusicInfo;

CREATE TABLE IF NOT EXISTS "MusicInfo" (
            name_en TEXT,
            name_zh TEXT,
            duration TEXT,
            isCharge INTEGER,
           'index' INTEGER,
            type INTEGER,
            flag INTEGER,
            price INTEGER,
            content TEXT,
            productId TEXT,
            imageUrl TEXT,
            downloadUrl TEXT,
            mp3FileName TEXT,
            backGroundImageUrl TEXT,
            ID TEXT primary key);

-- 添加数据 --
INSERT OR REPLACE INTO "MusicInfo" (
    mp3FileName,imageUrl,isCharge,name_en,name_zh,type,flag,'index',ID
    ) VALUES 
								 ('local_sleep_body.mp3','sleep_body.png',0,'Balance body','平衡身体',0,0,0,0),
    						   ('local_sleep_night.mp3','sleep_night.png',0,'Energy sleep','元气好眠',0,0,1,1),
    					    	('local_sleep_wave.mp3','sleep_wave.png',0,'Coastal sleep','海岸睡眠',0,0,2,2),
 ('local_meditation_happyHeaven.mp3','meditation_happyHeaven.png',0,'The nearest heaven','最后的天堂',0,1,0,3),
			      ('local_meditation_piano.mp3','meditation_piano.png',0,'Voice of nature','自然之声',0,1,1,4),
	('local_meditation_relaxation.mp3','meditation_relaxation.png',0,'Deep sea meditation','深海冥想',0,1,2,5);


UPDATE MusicInfo SET backGroundImageUrl = 'sleep_body_backImage.jpg' WHERE ID = 0;
UPDATE MusicInfo SET backGroundImageUrl = 'sleep_night_backImage.jpg' WHERE ID = 1;
UPDATE MusicInfo SET backGroundImageUrl = 'sleep_wave_backImage.jpg' WHERE ID = 2;