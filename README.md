# MFExtractColor

[Port of ColorArt code from OS X to iOS.](https://github.com/panicinc/ColorArt)

## 集成方式
- cocoapod
```
pod 'MFExtractColor'
```

## 效果



## about
(From the Panic blog: http://www.panic.com/blog/2012/12/itunes-11-and-colors/)

iTunes 11 is a radical departure from previous versions and nothing illustrates this more than the new album display mode. The headlining feature of this display is the new view style that visually matches the track listing to the album’s cover art. The result is an attractive display of textual information that seamlessly integrates with the album’s artwork.

After using iTunes for a day I wondered just how hard it would be to mimic this functionality — use a source image to create a themed image/text display.

Once I started filtering black and white backgrounds my results started to get a bit closer to iTunes. After doing some more analysis I saw that iTunes also looks for borders around the artwork. So lets say you have a solid white border around the artwork picture, iTunes will remove the border and base its theming colors off the remaining interior content. I didn’t add this functionality as it was outside the scope of my simple demo application.

After the background color was determined, the next step is to find contrasting text colors. Again, the first thing I tried was simple color counting, this provides surprisingly good results but iTunes does better. If we relied only on color frequency you’d get variants of the same color for the different types of text (EG: primary, secondary, detail). So the next thing I did to improve the results were to make sure the text colors were distinct enough from each other to be considered a separate color. At this point things were really starting to look good. But what other aspects would need to be considered to ensure the text always looked good on the chosen background color? To ensure colorful text I also added a bit of code to make sure the color used for the text had a minimum saturation level. This prevents washed out colors or very light pastel colors from being used that might not give the best appearance. Now that the text had unique colors that looked good with the background, the only remaining problem was that the resulting text colors could end up lacking enough contrast with the background to be readable. So the last thing I added was a check to make sure any text color would provide enough contrast with the background to be readable. Unfortunately this requirement does cause a rare “miss” when finding text colors which then cause the default black/white colors to be used.
