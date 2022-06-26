#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

// Avoiding name mangling
extern "C"
{
    // Attributes to prevent 'unused' function from being removed and to make it visible
    __attribute__((visibility("default"))) __attribute__((used))
    const char *version()
    {
        return CV_VERSION;
    }

    int clamp(int val){
        if(val < 0)
            return 0;
        else if(val > 255)
            return 255;
        else
            return val;
    }

    __attribute__((visibility("default"))) __attribute__((used)) 
    int get_distance(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int width, int height)
    {
        Mat mat_rgb;
        mat_rgb.create(height / 2, width / 2, CV_8UC3);

        int x, y, uvIndex, index;
        int yp, up, vp;
        int rt, gt, bt;

        for (y = height / 4; y < height * 3 / 4; y++) {
            for (x = width / 4; x < width * 3 / 4; x++) {
                uvIndex = (x + width*(y/2));
                index  = (y*width + x);

                yp = plane0[index];
                up = plane1[uvIndex];
                vp = plane2[uvIndex];

                rt = (yp + ((vp * 44915) >> 15) - 175);
                gt = (yp - (((up * 11063) + (vp * 22872)) >> 15) + 133);
                bt = (yp + ((up * 56769) >> 15) - 222);

                mat_rgb.at<Vec3b>(y - height / 4, x - width / 4)[0] = clamp(rt);
                mat_rgb.at<Vec3b>(y - height / 4, x - width / 4)[1] = clamp(gt);
                mat_rgb.at<Vec3b>(y - height / 4, x - width / 4)[2] = clamp(bt);
            }
        }

        Mat mat_hsv;
        cvtColor(mat_rgb, mat_hsv, COLOR_RGB2HSV);

        Mat green_threshold;
        inRange(mat_hsv, Scalar(40, 60, 20), Scalar(80, 255, 255), green_threshold);
        medianBlur(green_threshold, green_threshold, 9);
        Mat edge;
        Canny(green_threshold, edge, 150, 180);
        // GaussianBlur(mat_rgb, mat_rgb, Size(5, 5), 0);
        vector<vector<Point>> contours;
        vector<Vec4i> hierarchy;
        findContours(edge, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);

        Point2f center;
        float max_radius = 0;
        Point2f max_center;
        float radius;
        int length = contours.size();
        for (int i = 0; i < length; i++) {
            minEnclosingCircle(contours[i], center, radius);
            if (max_radius < radius) {
                max_radius = radius;
                max_center = center;
            }
        }

        return (int)max_radius;

        // Mat mat_rgba;
        // cvtColor(mat_rgb, mat_rgba, COLOR_RGB2RGBA);
        // if (max_radius != 0)
        // {
        //     circle(mat_rgba, max_center, (int)max_radius, Scalar(0, 255, 0, 255), 1);
        // }

        // return mat_rgba.data;
    }
}