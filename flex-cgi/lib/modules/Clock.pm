package Clock;

#use strict;

# Assign global variables.
use vars qw( %user_action );
use exporter;
use GD;

my $Clock_VERSION = '0.01';

# Define possible user actions.
%user_action = (
                clock => 1,
                clock2 => 1,
                );

# Analog Clock
sub clock {

# Remember how PostScript allows us to rotate the coordinate system?
# The PostScript version of the analog clock depended on this rotation ability to draw the ticks on the clock. Unfortunately,
# gd doesn't have functions for performing this type of manipulation. As a result, we use different algorithms in this program to draw the clock.

$delay = 3;
print "Refresh: ", $delay, "\n";
print "Content-type: image/gif", "\n\n";
$max_length = 150;
$image = new GD::Image ($max_length, $max_length);
$center = $radius = $max_length / 2;
@origin = ($center, $center);
$marker = 5;
$marker2 = 5;
$hour_segment = $radius * 0.50;
$minute_segment = $radius * 0.80;
$sec_segment = $radius * 0.85;
$deg_to_rad = (atan2 (1,1) * 4)/180;
$max_length -= 10;
$center222 = $radius = $max_length / 2;

# The @origin array contains the coordinates that represent the center of the image. In the PostScript version of this program, we translated (or moved) the origin to be at the center of the image. This is not possible with gd.
$white = $image->colorAllocate(255,255,255);
#$black = $image->colorAllocate (0, 0, 0);
$red = $image->colorAllocate (255, 0, 0);
$green = $image->colorAllocate (0, 255, 0);
$blue = $image->colorAllocate (0, 0, 255);
    $image->transparent($white);
    $image->interlaced('true');
# We create an image with a black background. The image also needs the red, blue, and green colors to draw the various parts of the clock.

($seconds, $minutes, $hour) = localtime (time);
$hour_angle = ($hour + ($minutes / 60) - 3) * 30 * $deg_to_rad;
$minute_angle = ($minutes + ($seconds / 60) - 15) * 6 * $deg_to_rad;
$sec_angle = ($seconds + ($seconds / 60) - 15) * 6 * $deg_to_rad;
$image->arc (@origin, $max_length, $max_length, 0, 360, $blue);

# Using the current time, we calculate the angles for the hour and minute hands of the clock. We use the arc method to draw a blue circle with the center at the "origin" and a diameter of max_length.

for ($loop=0; $loop < 360; $loop = $loop + 30) {
local ($degrees) = $loop * $deg_to_rad;
$image->line ($origin[0] + (($radius - $marker) * cos ($degrees)),
              $origin[1] + (($radius - $marker) * sin ($degrees)),
              $origin[0] + ($radius * cos ($degrees)),
              $origin[1] + ($radius * sin ($degrees)),
              $red);
# This loop draws the ticks representing the twelve hours on the clock. Since gd lacks the ability to rotate the axes, we need to calculate the coordinates for these ticks. The basic idea behind the loop is to draw a red line from a point five pixels away from the edge of the circle to the edge.

$image->line ( @origin,
        $origin[0] + ($hour_segment * cos ($hour_angle)),
        $origin[1] + ($hour_segment * sin ($hour_angle)),
                $green  );

$image->line (   @origin,
        $origin[0] + ($minute_segment * cos ($minute_angle)),
        $origin[1] + ($minute_segment * sin ($minute_angle)),
                $green  );
$image->line (   @origin,
        $origin[0] + ($sec_segment * cos ($sec_angle)),
        $origin[1] + ($sec_segment * sin ($sec_angle)),
                $blue  );
 }
# Using the angles that we calculated earlier, we proceed to draw the hour and minute hands with the line method.

$image->arc (@origin, 4, 4, 0, 360, $red);
$image->fill ($origin[0] + 1, $origin[1] + 1, $red);
binmode STDOUT;
print $image->gif;
exit(0);

# We draw a red circle with a radius of 6 at the center of the image and fill it. Finally, the GIF image is output with the gif method.

}

# Digital Clock
sub clock2 {

# Here is an example of a digital clock, which is identical to the PostScript version in functionality.
# However, the manner in which it is implemented is totally different.
# This program loads the gd graphics library, and uses its functions to create the image.

$delay = 3;
print "Refresh: ", $delay, "\n";
print "Content-type: image/gif", "\n\n";

# In Perl 5.0, external modules, such as gd, can be "included" into a program with the use statement. Once the module is included, the program has full access to the functions within it.

($seconds, $minutes, $hour) = localtime (time);
if ($hour > 12) {
        $hour -= 12;
        $ampm = "pm";
} else {
        $ampm = "pm";
}
if ($hour == 0) {
    $hour = 12;
}
$time = sprintf ("%02d:%02d:%02d %s", $hour, $minutes, $seconds, $ampm);
$time_length = length($time);
$font_length = 8;
$font_height = 16;
$x = $font_length * $time_length;
$y = $font_height;

# Unlike the analog clock PostScript example, we will actually calculate the size of the image based on the length of the string stored in the variable $time. The reason we didn't elect to do this in the PostScript version is because Times-Roman is not a constant-width font, and so we would have to do numerous calculations to determine the exact dimensions of our dynamic image. But with gd, there are only a few constant-width fonts, so we can calculate the size of the image rather easily.
#
# We use the length function to determine the length (i.e., the number of characters) of the string stored in $time. The image length is calculated by multiplying the font length with the string length. The font we will use is gdLarge, which is an 8x16 constant-width font.

$image = new GD::Image ($x, $y);

# Images are "created" by calling the method Image within the GD class, which creates a new instance of the object. For readers not familiar with object-oriented languages, here is what the statement means:
#
#    * The new keyword causes space to be allocated for the image.
#
#    * The GD is the class, which means what kind of object we're making (it happens to have the same name as the package we loaded with the use statement).
#
#    * Within that class is a function (or method) called Image, which takes two arguments.
#
# Note that the whole statement creating an image ends up returning a handle, which we store in $image. Now, following traditional object-oriented practice, we can call functions that are associated with an object method, which operates on the object. You'll see that below.
#
# The dimensions of the image are passed as arguments to the Image method. An important difference between PostScript and gd with regard to drawing is the location of the origin. In gd, the origin is located in the upper-left corner, compared to the lower-left corner for PostScript.

$black = $image->colorAllocate (0, 0, 0);
$red = $image->colorAllocate (255, 0, 0);

# The -> part of the function is another object-oriented idea. When you set a color, you naturally have to specify what you're coloring. In object-oriented programming, $image is the object and you tell that object to execute the method. So $image->colorAllocate is Perl 5.0's way of saying, "color the object denoted by $image." The three arguments that the colorAllocate method expects are the red, blue, and green indices in the range 0--255.
#
# The first color that we allocate automatically becomes the background color. In this case, the image will have a black background.

$image->string (gdLargeFont, 0, 0, $time, $red);
print $image->gif;
exit(0);

# The string method displays text at a specific location on the screen with a certain font and color. In our case, the time string is displayed using the red large font at the origin. The most important statement in this entire program is the print statement, which calls the gif method to display the drawing in GIF format to standard output.
#
# You should have noticed some major differences between PostScript and gd. PostScript has to be run through an interpreter to produce GIF output, while gd can be smoothly intermixed with Perl. The origin in PostScript is located in the lower-left corner, while gd's origin is the upper left corner. And most importantly, simple images can be created in gd much more easily than in PostScript; PostScript should be used for creation of complex images only.

}

1;