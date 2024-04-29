const float sunPathRotation = -35.0;

#define CSM
#define CSM_CASCADES 4 // Currently, only 4 is supported by this implementation.

//#define CSM_VISUALIZE_CASCADES

// Margins around the outer edge of the cascade to accomodate simple filtering
#define CSM_CASCADE_MARGIN_BLOCKS 0.0
// Nearest filtered shadow taps: +0 pixels
// Bilinear filtered shadow taps: +0.5 pixels on each side
// Midpoint rounding: +1 pixel on each axis, AKA +0.5 pixels on each side
#define CSM_CASCADE_MARGIN_PIXELS 1.0

const int shadowMapResolution = 2048; // [512 768 1024 1536 2048 3072 4096 6144 8192]
const float shadowDistance = 128; // [16 32 48 64 80 96 112 128 144 160 176 192 208 224 240 256 272 288 304 320 336 352 368 384 400 416 432 448 464 480 496 512 528 544 560 576 592 608 624 640 656 672 688 704 720 736 752 768 784 800 816 832 848 864 880 896 912 928 944 960 976 992 1008 1024]
const float shadowDistanceRenderMul = 1.0;
const bool shadowHardwareFiltering1 = true;
