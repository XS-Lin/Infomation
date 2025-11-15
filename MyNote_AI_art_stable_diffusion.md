# AI Art #

## 参考 ##

### Youtube ###

[AI 繪圖教學觀看順序](https://www.youtube.com/playlist?list=PLA8oR-9gke1--n2RNoWzhwDSgggvxjjOL)
[StableDiffusion的内部结构和工作原理](https://www.youtube.com/watch?v=rz89oownA6M)

### 参考資料 ###

[doc openpose](https://cmu-perceptual-computing-lab.github.io/openpose/web/html/doc/md_doc_installation_0_index.html)
[github stable diffusion](https://github.com/CompVis/stable-diffusion)
[github stable diffusion web ui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
[github webui-llul](https://github.com/hnmr293/sd-webui-llul)
[github ControlNet](https://github.com/Mikubill/sd-webui-controlnet)
[Depth map library and poser](https://github.com/jexom/sd-webui-depth-lib)
[pose site: posemaniacs](https://www.posemaniacs.com/ja/poses/sitting)
[chart gpt](https://chat.openai.com/chat)
[stable-diffusion-models](https://cyberes.github.io/stable-diffusion-models/)
[TencentARC](https://github.com/TencentARC/GFPGAN)
[GFPGANv1.4.pth](https://github.com/TencentARC/GFPGAN/releases/download/v1.3.4/GFPGANv1.4.pth)
[civitai 水中](https://civitai.com/images/110973?modelVersionId=5119)
[civitai ulzzang-6500-v1.1.bin](https://civitai.com/api/download/models/10107)
[魔咒百科词典](http://aitag.top/)
[nvida cudnn](https://developer.download.nvidia.com/compute/redist/cudnn/)
[cudnn-windows-x86_64-8.7.0.84_cuda11-archive.zip](https://developer.download.nvidia.com/compute/redist/cudnn/v8.7.0/local_installers/11.8/)
[Additional Networks for generating images](https://github.com/kohya-ss/sd-webui-additional-networks)
[github Ultimate SD Upscale extension](https://github.com/Coyote-A/ultimate-upscale-for-automatic1111)

### Model ###

[CompVis v1.4](https://huggingface.co/CompVis/stable-diffusion-v1-4)
[hakurei waifu v1.3](https://huggingface.co/hakurei/waifu-diffusion-v1-3)
[ControlNet models](https://huggingface.co/lllyasviel/ControlNet/tree/main/models)
[Model Database - 4x-UltraSharp](https://upscale.wiki/wiki/Model_Database)

https://civitai.com/models/4384/dreamshaper
https://civitai.com/models/10028/neverending-dream
https://civitai.com/models/23521/anime-pastel-dream

## インストール ##

1. インストール python3.10
2. gitでstable-diffusion-webuiをダウンロード
3. GFPGANv1.4.pthをstable-diffusion-webuiフォルダに配置
4. ulzzang-6500-v1.1.binをstable-diffusion-webui\embeddingsフォルダに配置、名前をulzzang.binに変更
5. webui-user.batの「set COMMANDLINE_ARGS=--xformers」編集
6. 拡張インストール Kohya-ss Additional Networks
7. RoLAモデル格納フォルダ stable-diffusion-webui\extensions\sd-webui-additional-networks\models\lora
8. [VAE](https://huggingface.co/stabilityai/sd-vae-ft-mse-original/tree/main)の「vae-ft-mse-840000-ema-pruned.safetensors」をstable-diffusion-webui\models\VAE に配置し、Settings > Stable Diffusion > SD VAE を変更してApply settings
9. ControlNet設定
  * Enable CFG-Based guidance: checked
10. [upgrade touch](https://pytorch.org/)
  * pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
11. [update cudnn](https://www.reddit.com/r/StableDiffusion/comments/y71q5k/4090_cudnn_performancespeed_fix_automatic1111/)
  * cudnn-windows-x86_64-8.7.0.84_cuda11-archive.zip\bin\以下の内容をstable-diffusion-main\venv\Lib\site-packages\torch\libに格納
12. [github xformers](https://github.com/facebookresearch/xformers#installing-xformers)
  * pip install -U xformers

### RoLA ###

[kiss-shot acerola-orion heart-under-blade](https://civitai.com/api/download/models/8588)
[Yae Miko | Realistic Genshin LORA](https://civitai.com/models/8484/yae-miko-or-realistic-genshin-lora)
https://civitai.com/models/8484/yae-miko-or-realistic-genshin-lora
https://civitai.com/models/8730/hipoly-3d-model-lora
https://civitai.com/models/4830/shenhe-lora-collection-of-trauters
[中国](https://civitai.com/models/11352/3lora-guofeng3lora)
https://civitai.com/models/7256/yor-briar-spy-family-lora
[アジア]https://civitai.com/models/23337/urban-samurai-or-clothing-lora
https://civitai.com/models/5042/wlop-style-lora
https://civitai.com/models/5977/shinobu-kochou-demon-slayer-lora
[姐弟](https://civitai.com/models/21618/two-person-lora-lora-update-for-character-lora)
[アスナ](https://civitai.com/models/4718/asuna-lora)
[欧米](https://civitai.com/models/24138/wedding-dress-extension-or-clothing-lora)
[SAO](https://civitai.com/models/23707/sword-art-online-girlpack-lora)
https://civitai.com/models/26296/evangelion-1995-style-lora
[Grav_Qunqun_TW](https://civitai.com/models/22211/gravqunquntw)
[Grav_Yangyang_TW](https://civitai.com/models/22866/gravyangyangtw)
https://civitai.com/models/22959/female-noble-class-hanbok-korea-clothes
https://civitai.com/models/26124/koreandolllikeness-v20
https://civitai.com/models/19356/koreandolllikenessv10
https://civitai.com/models/17497/taiwan-doll-likeness
https://civitai.com/models/19044/japanese-doll-likeness
https://civitai.com/models/13068/russian-doll-likeness

### pt ###

[bad-hands-5](https://huggingface.co/yesyeahvh/bad-hands-5/tree/main)

## 起動 ##

~~~powershell
cd E:\tool\ai\stable-diffusion-webui
py -3.11 -m venv .venv
.venv\Scripts\activate
.\webui-user.bat
~~~

## 機能 ##

### PNG Info ###

過去生成した画像の呪文を取得できる

### txt2img ###

Restore faces: 顔を修正
Hires fix: 大きい画像生成
CFG Scale: 呪文との関連性を強化、よく使われる値 8 or 10
Seed: 同じシードで生成した画像の類似度は高い
prompt: (content,weight) 強調、[]減少

### img2img ###

Inpaint: 再生成する/しない部分をマスク

## 呪文 ##

### 0 共通 ###

* プロンプトの強調と控えめ
  * ()で囲むと1.1倍強く出す
  * (())と重ねて囲むと乗算で強調（2重なら1.1x1.1の1.21倍）
  * []で囲むと1.1倍控えめに出す（強さを/1.1＝約0.909倍で下げる）
  * (ward:1.5)と囲った中の最後尾に「:数値」を入れた場合は入力数値の倍率で強調する（1.5なら1.5倍）
  * (ward:0.25)と数値を1.0未満にすればその分控えめになる
    * 控えめに使う方での[ward:1]は全く別物の条件指定になるため強調控えめ指定には使えない
    * 単体で確かめると気づくが倍率が高すぎると形にならない＝機能しなくなる可能性がある。大きくても1.6前後が丁度良く、限度は2.0くらい。(())指定なら5重まで、限度7～8重ほど
    * ()や[]の中には((A,B,C,D))と複数の言葉を入れても問題無い

* タイミング条件付きプロンプト(Prompt Editing)
  * [条件前呪文:条件後呪文:条件数値] - [ward:1]の指定はタイミングを指定したprompt条件指定に使える。
    * 条件数値:step数かsteps割合を指定する。
      * 整数指定(8とか20とか)はその値が条件step回数になる
      * 小数指定(0.3とか0.5とか)は指定steps * 指定数値が条件step回数になる
    * 条件前呪文:stepが条件step回数になるまでprompt文として影響を与える（省略可能）
    * 条件後呪文:stepが条件step回数になった後からprompt文として影響を与える（空欄可能）
      * この呪文内にも()や[]を使っても問題ない。条件を入れ子にしても機能する

* 呪文の構成
  * 主題
  * 画風
  * 画質

nvidia-smi

論文
https://arxiv.org/

~~~txt
Prompt:

Negative Prompt:
(bad-hands-5:1.0)
~~~

### 1 女性写真 ###

~~~txt
Prompt:
RAW photo, delicate, best quality, (intricate details:1.3), hyper detail, finely detailed, colorful, 1girl, solo, 8k uhd, film grain, (studio lighting:1.2), (Fujifilm XT3), (photorealistic:1.3), (detailed skin:1.2),1 girl,cute, solo,beautiful detailed sky,detailed cafe,dating,(nose blush),(smile:1.15),(closed mouth), middle breasts,beautiful detailed eyes, daylight, wet, rain, (short hair:1.2),floating hair NovaFrogStyle, full body,turtleneck,ribbed sweater,see-through,wet clothes

Negative Prompt:
paintings, sketches, (worst quality:2), (low quality:2), (normal quality:2), lowres, normal quality, ((monochrome)), ((grayscale)), skin spots, acnes, skin blemishes, age spot, (outdoor:1.6), manboobs, backlight,(ugly:1.331), (duplicate:1.331), (morbid:1.21), (mutilated:1.21), (tranny:1.331), mutated hands, (poorly drawn hands:1.331), blurry, (bad anatomy:1.21), (bad proportions:1.331), extra limbs, (disfigured:1.331), (more than 2 nipples:1.331), (missing arms:1.331), (extra legs:1.331), (fused fingers:1.61051), (too many fingers:1.61051), (unclear eyes:1.331), bad hands, missing fingers, extra digit, (futa:1.1), bad body, NG_DeepNegative_V1_75T,pubic hair, glans
~~~

~~~txt
masterpiece, (best quality:1.2), (ultra-detailed:1.2), illustration, (an extremely delicate and beautiful:1.2),cinematic angle,floating, (beautiful detailed eyes:1.1), (detailed light:1.1),cinematic lighting, beautifully detailed sky, women, white hair, blue eyes, (high ponytail:1.1), cloak, glowing eyes, (moon:1.2), (moonlight:1.1), starry sky, (lighting particle:1.1), fog, snow painting, sketch, bloom
Negative prompt: illustration, 3d, sepia, painting, cartoons, sketch, (worst quality:2), (low quality:2), (normal quality:2), lowres, bad anatomy, bad hands, normal quality, ((monochrome)), ((grayscale:1.2)), futanari, full-package_futanari, penis_from_girl, newhalf, collapsed eyeshadow, multiple eyebrows, vaginas in breasts,holes on breasts, fleckles, stretched nipples, gigantic penis, nipples on buttocks, analog, analogphoto, signatre, logo,2 faces
Steps: 30, Sampler: Euler a, CFG scale: 7, Seed: 3141884919, Face restoration: CodeFormer, Size: 600x900, Model hash: fc2511737a, Model: chilloutmix_NiPrunedFp32Fix, ENSD: 31337, Eta: 0.667
~~~

~~~txt
masterpiece, (best quality), (ultra-detailed), (an extremely delicate and beautiful),cinematic angle, (beautiful detailed eyes:1.1), (detailed light:1.1), beautifully detailed sky, 1girl, (high ponytail:1.1), cloak, glowing eyes, (moon:1.2), (moonlight:1.1), starry sky, (lighting particle:1.1), fog, snow painting, bloom, (white hair),
Negative prompt: illustration, sepia, painting, cartoons, sketch, (worst quality), (low quality), (normal quality), lowres, bad anatomy, bad hands, normal quality, ((monochrome)), ((grayscale:1.2)), futanari, full-package_futanari, penis_from_girl, newhalf, collapsed eyeshadow, multiple eyebrows, vaginas in breasts,holes on breasts, fleckles, stretched nipples, gigantic penis, nipples on buttocks, analog, analogphoto, signatre,2 faces
Steps: 30, Sampler: Euler a, CFG scale: 7, Seed: 4199249091, Face restoration: CodeFormer, Size: 600x900, Model hash: 54214af774, Model: sunshinemix_sunlightmixPruned, ENSD: 31337, Eta: 0.667
~~~

~~~txt
middle breasts,complex 3d render ultra detailed of a beautiful porcelain profile woman android face, cyborg, robotic parts, 150 mm, beautiful studio soft light, rim light, vibrant details, luxurious cyberpunk, lace, hyperrealistic, anatomical, facial muscles, cable electric wires, microchip, elegant, beautiful background, octane render, H. R. Giger style, 8k, best quality, masterpiece, illustration, an extremely delicate and beautiful, extremely detailed ,CG ,unity ,wallpaper, (realistic, photo-realistic:1.37),Amazing, finely detail, masterpiece,best quality,official art, extremely detailed CG unity 8k wallpaper, absurdres, incredibly absurdres, robot, silver halmet, full body
Negative prompt: illustration, 3d, sepia, painting, cartoons, sketch, (worst quality:2), (low quality:2), (normal quality:2), lowres, bad anatomy, bad hands, normal quality, ((monochrome)), ((grayscale:1.2)), futanari, full-package_futanari, penis_from_girl, newhalf, collapsed eyeshadow, multiple eyebrows, vaginas in breasts,holes on breasts, fleckles, stretched nipples, gigantic penis, nipples on buttocks, analog, analogphoto, signatre, logo,2 faces
Steps: 30, Sampler: DPM++ SDE Karras, CFG scale: 7, Seed: 1330113975, Face restoration: CodeFormer, Size: 600x900, Model hash: 54214af774, Model: sunshinemix_sunlightmixPruned
~~~

~~~txt
cyborg, robotic parts, 150 mm, beautiful studio soft light, rim light, vibrant details, luxurious cyberpunk, lace, hyperrealistic, anatomical, facial muscles, cable electric wires, microchip, elegant, octane render, H. R. Giger style, best quality, masterpiece, illustration, extremely detailed, finely detail, masterpiece,official, i<lora:japanesedolllikenessV1_v15:0.1>, <lora:koreanDollLikeness_v10:0.5>, robot, silver halmet, full body, sitting, <lora:chilloutmixss_xss10:0.5>,cleavage
Negative prompt: sepia, painting, cartoons, sketch, (worst quality:2), (low quality:2), (normal quality:2), lowres, bad anatomy, bad hands, normal quality, ((monochrome)), ((grayscale:1.2)), futanari, full-package_futanari, penis_from_girl, newhalf, collapsed eyeshadow, multiple eyebrows, vaginas in breasts,holes on breasts, fleckles, stretched nipples, gigantic penis, nipples on buttocks, analog, analogphoto, signatre, logo,2 faces
Steps: 20, Sampler: DPM++ SDE Karras, CFG scale: 7, Seed: 1806642520, Face restoration: CodeFormer, Size: 512x784, Model hash: 54214af774, Model: sunshinemix_sunlightmixPruned, ENSD: 31337
~~~

~~~txt
NOTE: 18+

complex 3d render ultra detailed of a beautiful porcelain profile woman android face, cyborg, robotic parts, 150 mm, beautiful studio soft light, rim light, vibrant details, luxurious cyberpunk, lace, hyperrealistic, anatomical, facial muscles, cable electric wires, microchip, elegant, beautiful background, octane render, H. R. Giger style, 8k, best quality, masterpiece, illustration, an extremely delicate and beautiful, extremely detailed ,CG ,unity ,wallpaper, (realistic, photo-realistic:1.37),Amazing, finely detail, masterpiece,best quality,official art, extremely detailed CG unity 8k wallpaper, absurdres, incredibly absurdres,  <lora:japaneseDollLikeness_v10:0.1>, <lora:koreanDollLikeness_v10:0.5>, robot, silver halmet, full body, sitting
Negative prompt: illustration, 3d, sepia, painting, cartoons, sketch, (worst quality:2), (low quality:2), (normal quality:2), lowres, bad anatomy, bad hands, normal quality, ((monochrome)), ((grayscale:1.2)), futanari, full-package_futanari, penis_from_girl, newhalf, collapsed eyeshadow, multiple eyebrows, vaginas in breasts,holes on breasts, fleckles, stretched nipples, gigantic penis, nipples on buttocks, analog, analogphoto, signatre, logo,2 faces
Size: 512x784, Seed: 21364683354, Model: chilloutmix_NiPrunedFp32Fix, Steps: 33, Sampler: DPM++ SDE Karras, CFG scale: 7, Model hash: fc2511737a
~~~

~~~txt
NOTE: 18+

RAW photo, best quality, high resolution, (masterpiece), (photorealistic:1.4), professional photography, sharp focus, HDR, 8K resolution, intricate detail, sophisticated detail, depth of field, extremely detailed CG unity 8k wallpaper, (front light), NSFW, (full body nude:1.2), 1girl, standing, 18 yo beautiful supermodel, (smiling:1.3), random color and style hair, very skinny slender fit-muscled body, thin waist, long legs, tall height, (naturally sagging enormous breasts:1.2), extremely detailed face eyes lips areolas nipples pussy and highheels, (looking at viewer:1.1), (high gloss sweaty skin:1.2), highly detailed public background, (Kpop idol makeup), (PureErosFace_V1:0.3)
Negative prompt: (EasyNegative:1.0), paintings, sketches, lowres, (monochrome), (grayscale), polar lowres, jpeg artifacts, text, watermark, white letters, (worst quality:2), (low quality:2), (normal quality:2), signature, watermark, username, blurry, poorly drawn hands, poorly drawn face, mutation, deformed, {Multiple people}, cropped, extra digit, fewer digits, error, extra limbs, extra arms, extra legs, fused fingers, too many fingers, malformed limbs, skin spots, acnes, skin blemishes, age spot, glans, extra fingers, fewer fingers, multi nipples, bad anatomy, bad hands, bad feet, long neck, cross-eyed, mutated hands, fused fingers, too many fingers, extra digit, fewer digits, missing fingers, malformed limbs, extra limbs, extra arms, extra legs, missing arms, missing legs, bad body, bad proportions, gross proportions, wrong feet bottom render, abdominal stretch, (fused fingers), (bad body), pants, briefs, knickers, kecks, thong, bra, covered nipples, underwear
Size: 512x1280, Seed: 3393406027, Model: chilloutmix_NiPrunedFp32Fix, Steps: 20, Sampler: DPM++ SDE Karras, CFG scale: 7, Model hash: fc2511737a, Face restoration: CodeFormer

(RAW photo, best quality), (realistic, photo-realistic:1.3), best quality ,masterpiece, an extremely delicate and beautiful, extremely detailed ,CG ,unity ,2k wallpaper, Amazing, finely detail, masterpiece,light smile,best quality, extremely detailed CG unity 8k wallpaper,huge filesize , ultra-detailed, highres, extremely detailed, iu,asymmetrical bangs,short bangs,bangs,pureerosface_v1,beautiful detailed girl, extremely detailed eyes and face, beautiful detailed eyes,light on face,looking at viewer, straight-on, staring, closed mouth,black hair,long hair, collarbone, bare shoulders, longeyelashes,breasts,nipples,upper body, lace ,lace trim,1girl,nude, naked girl, (full body:1.3), (highly detail face: 1.5), (beautiful ponytail:0.5),beautiful detailed eyes, beautiful detailed nose, vaginal detailed, nipples, realistic face, realistic body, beautiful pussy, pussy detail, comfortable expressions, thigh spread,smile, look at viewer,(ass to camera:1.1),comfortable expressions, ((thigh spread)), (ass in the mirror:1.1),ass detail,<lora:koreanDollLikeness_v15:0.3> , <ulzzang-6500:0.4>
Negative prompt: bra, covered nipples, underwear,EasyNegative, paintings, sketches, (worst quality:2), (low quality:2), (normal quality:2), lowres, normal quality, ((monochrome)), ((grayscale)), skin spots, acnes, skin blemishes, age spot, glans,extra fingers,fewer fingers,((watermark:2)),(white letters:1), (multi nipples), lowres, bad anatomy, bad hands, text, error, missing fingers,extra digit, fewer digits, cropped, worst quality, low qualitynormal quality, jpeg artifacts, signature, watermark, username,bad feet, {Multiple people},lowres,bad anatomy,bad hands, text, error, missing fingers,extra digit, fewer digits, cropped, worstquality, low quality, normal quality,jpegartifacts,signature, watermark, blurry,bad feet,cropped,poorly drawn hands,poorly drawn face,mutation,deformed,worst quality,low quality,normal quality,jpeg artifacts,signature,extra fingers,fewer digits,extra limbs,extra arms,extra legs,malformed limbs,fused fingers,too many fingers,long neck,cross-eyed,mutated hands,polar lowres,bad body,bad proportions,gross proportions,text,error,missing fingers,missing arms,extra arms,missing legs,wrong feet bottom render,extra digit,abdominal stretch, glans, pants, briefs, knickers, kecks, thong, {{fused fingers}}, {{bad body}}
Size: 512x1424, Seed: 4198779528, Model: chilloutmix_NiPrunedFp32Fix, Steps: 25, Sampler: DPM++ SDE Karras, CFG scale: 8.5, Model hash: fc2511737a
~~~

~~~txt
# guofeng3 手はよくないので修復が必要

modelshoot style, (extremely detailed CG unity 8k wallpaper), full shot body photo of the most beautiful artwork in the world, medieval armor, professional majestic oil painting by Ed Blinkey, Atey Ghailan, Studio Ghibli, by Jeremy Mann, Greg Manchess, Antonio Moro, trending on ArtStation, trending on CGSociety, Intricate, High Detail, Sharp focus, dramatic, photorealistic painting art by midjourney and greg rutkowski
Negative prompt: (((simple background))),monochrome ,lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry, lowres, bad anatomy, bad hands, text, error, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry, ugly,pregnant,vore,duplicate,morbid,mut ilated,tran nsexual, hermaphrodite,long neck,mutated hands,poorly drawn hands,poorly drawn face,mutation,deformed,blurry,bad anatomy,bad proportions,malformed limbs,extra limbs,cloned face,disfigured,gross proportions, (((missing arms))),(((missing legs))), (((extra arms))),(((extra legs))),pubic hair, plump,bad legs,error legs,username,blurry,bad feet
ENSD: 31337, Size: 768x1024, Seed: 1029520448, Model: gf_anylora_gf3.2_anylora1.2, Steps: 30, Sampler: Euler a, CFG scale: 9, Clip skip: 2, Model hash: 4078eb4174
~~~

~~~txt
# guofeng3 手はよくないので修復が必要


best quality, masterpiece, highres, 1girl,blush,(seductive smile:0.8),star-shaped pupils,china hanfu,hair ornament,necklace, jewelry, upon_body, tyndall effect,photorealistic, dark studio, rim lighting, two tone lighting,(high detailed skin:1.2), 8k uhd, soft lighting, high quality, volumetric lighting, candid, Photograph, high resolution, 4k, Bokeh
Negative prompt: (simple background),monochrome , bad hands, missing fingers, (more fingers),extra digit, cropped, worst quality, jpeg artifacts, hermaphrodite,long neck,mutated hands,poorly drawn hands,poorly drawn face,disfigured,gross proportions, ((missing arms)),((missing legs)), ((extra arms)),((extra legs)),pubic hair, plump,bad legs,error legs,blurry,bad feet
Steps: 30, Sampler: Euler a, CFG scale: 9, Seed: 3556647833, Face restoration: CodeFormer, Size: 640x1024, Model hash: 4078eb4174, Model: 3Guofeng3_v33
~~~

### 2 LoRA | VAE | chilloutmix-Ni ###

~~~txt
Prompt:
(8k, best quality, masterpiece:1.2), (realistic, photo-realistic:1.37), ultra-detailed, 1 girl,cute, solo,beautiful detailed sky,detailed cafe,night,sitting,dating,(nose blush),(smile:1.15),(closed mouth) small breasts,beautiful detailed eyes,(collared shirt:1.1), night, wet,business attire, rain,white lace, (short hair:1.2),floating hair NovaFrogStyle,

Negative Prompt:
paintings, sketches, (worst quality:2), (low quality:2), (normal quality:2), lowres, normal quality, ((monochrome)), ((grayscale)), skin spots, acnes, skin blemishes, age spot, (outdoor:1.6), manboobs, backlight,(ugly:1.331), (duplicate:1.331), (morbid:1.21), (mutilated:1.21), (tranny:1.331), mutated hands, (poorly drawn hands:1.331), blurry, (bad anatomy:1.21), (bad proportions:1.331), extra limbs, (disfigured:1.331), (more than 2 nipples:1.331), (missing arms:1.331), (extra legs:1.331), (fused fingers:1.61051), (too many fingers:1.61051), (unclear eyes:1.331), bad hands, missing fingers, extra digit, (futa:1.1), bad body, NG_DeepNegative_V1_75T,pubic hair, glans

Restore faces: checked
Sampling method: DPM++ SDE Karras
Sampling steps: 28
Additional Networks
  taiwanDollLikeness_v1.safetensors weight:0.15
  koreandolllikeness_V10.safetensors weight:0.2
width: 648
height: 880
CFG Scale: 8
~~~

### 3 動作 ###

~~~txt
Prompt:
(8k, best quality, masterpiece:1.2), (realistic, photo-realistic:1.37), ultra-detailed, 1 girl,cute, solo,beautiful detailed sky,sitting,dating,(nose blush),(smile:1.15),(closed mouth) big breasts,beautiful detailed eyes,(collared shirt:1.1), (short hair:1.3),(floating hair NovaFrogStyle:1.2), jk,night, pink light, wet, park

Negative Prompt:
paintings, sketches, (worst quality:2), (low quality:2), (normal quality:2), lowres, normal quality, ((monochrome)), ((grayscale)), skin spots, acnes, skin blemishes, age spot, (outdoor:1.6), manboobs, backlight,(ugly:1.331), (duplicate:1.331), (morbid:1.21), (mutilated:1.21), (tranny:1.331), mutated hands, (poorly drawn hands:1.331), blurry, (bad anatomy:1.21), (bad proportions:1.331), extra limbs, (disfigured:1.331), (more than 2 nipples:1.331), (missing arms:1.331), (extra legs:1.331), (fused fingers:1.61051), (too many fingers:1.61051), (unclear eyes:1.331), bad hands, missing fingers, extra digit, (futa:1.1), bad body, NG_DeepNegative_V1_75T,pubic hair, glans, missing foots

Restore faces: checked
Sampling method: DPM++ SDE Karras
Sampling steps: 28
width: 512
height: 800
CFG Scale: 8
Additional Networks
  taiwanDollLikeness_v1.safetensors weight:0.15
  koreandolllikeness_V10.safetensors weight:0.2
ControlNet
  Enabled: checked
  Preprocessor: openpose
  Model: control_sd15_openpose
  Canvan Width: 660
  Canvas Height: 1290
  ※Canvan WidthとCanvas Height参照画像と一致にする。
~~~
