interface ImageSortable
{
    PImage getImage();
}

class BrightnessComparator implements Comparator<ImageSortable>
{
    @Override
	public int compare(ImageSortable arg1, ImageSortable arg2)
    {
        color c1 = getAverageColor(arg1.getImage());
        color c2 = getAverageColor(arg2.getImage());
		if (brightness(c1) < brightness(c2)) { return 1; }
		else if (brightness(c1) == brightness(c2)) { return 0; }
		else { return -1; }
	}

    private color getAverageColor(PImage img)
    {
        int imgSize = img.width*img.height;
        int red = 0, green = 0, blue = 0;
        img.loadPixels();
        for (int i = 0; i < imgSize; i++)
        {
            color c = img.pixels[i];
            red += red(c);
            green += green(c);
            blue += blue(c);
        }
        red /= imgSize;
        green /= imgSize;
        blue /= imgSize;

        return color(red, green, blue);
    }
}