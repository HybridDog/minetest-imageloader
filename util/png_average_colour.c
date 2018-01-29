#include <stdlib.h> // malloc, EXIT_*
#include <string.h> // memset
#include <png.h>
#include <math.h>

#define GAMMA_CORRECT 1


#define CLAMP(A, B, V) ((V) < (A) ? (A) : (V) > (B) ? (B) : (V))
#define TO_U8(V) CLAMP(0, 255, floor((V) * 255.0 + 0.5))

#define EXIT_PNG(F) if (!F) { \
	fprintf(stderr, "%s\n", bild.message); \
	return EXIT_FAILURE; \
}

int main()
{
	png_image bild;
	memset(&bild, 0, sizeof(bild));
	bild.version = PNG_IMAGE_VERSION;
	EXIT_PNG(png_image_begin_read_from_stdio(&bild, stdin))

	int w = bild.width;
	int h = bild.height;
	bild.format = PNG_FORMAT_RGBA;

	struct px {
		unsigned char r;
		unsigned char g;
		unsigned char b;
		unsigned char a;
	};
	struct px *pixels = malloc(w * h * 4);
	EXIT_PNG(png_image_finish_read(&bild, NULL, pixels, 0, NULL))

	double r, g, b;
	r = g = b = 0.0;
	double cnt = 0.0;
	for (int i = 0; i < w * h; ++i) {
		struct px *pixel = &pixels[i];
		double f = pixel->a / 255.0;
		cnt += f;
#if GAMMA_CORRECT
		r += f * pow(pixel->r / 255.0, 2.2);
		g += f * pow(pixel->g / 255.0, 2.2);
		b += f * pow(pixel->b / 255.0, 2.2);
#else
		r += f * pixel->r;
		g += f * pixel->g;
		b += f * pixel->b;
#endif
	}
#if GAMMA_CORRECT
	struct px result = (struct px){TO_U8(pow(r / cnt, 1.0 / 2.2)),
		TO_U8(pow(g / cnt, 1.0 / 2.2)), TO_U8(pow(b / cnt, 1.0 / 2.2)), 0};
#else
	struct px result = (struct px){TO_U8(r / cnt), TO_U8(g / cnt),
		TO_U8(b / cnt), 0};
#endif
	printf("r=%d, g=%d, b=%d", result.r, result.g, result.b);

	return EXIT_SUCCESS;
}
