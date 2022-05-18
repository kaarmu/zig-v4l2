/// V4L2 definitions and constants from the original v4l2 header file.
///
///
/// This file is part of [zig-v4l2](https://github.com/kaarmu/zig-v4l2).
/// Copyright (c) 2022 Kaj Munhoz Arfvidsson

const std = @import("std");

// ----------------------------------- //
// Common stuff for both V4L1 and V4L2 //
// Moved from videodev.h               //
// ----------------------------------- //

pub const VIDEO_MAX_FRAME = 32;
pub const VIDEO_MAX_PLANES = 8;

// --------------------------------- //
//     M I S C E L L A N E O U S     //
// --------------------------------- //

/// Four-character-code
pub inline fn fourcc(comptime cc: [4]u32) u32 {
    var out: u32 = 0;
    inline for (cc) |v, i| {
        out |= a << 8*i;
    }
    return out;
}

pub inline fn fourcc_be(comptime cc: [4]u32) u32 {
    return fourcc(cc) | (1 << 31);
}


// ----------------- //
//     E N U M S     //
// ----------------- //

/// v4l2_field
pub const Field = extern enum(u32) {
    /// driver can choose from none,
    /// top, bottom, interlaced
    /// depending on whatever it thinks
    /// is approximate ...
    ANY           = 0,
    /// this device has no fields ...
    NONE          = 1,
    /// top field only
    TOP           = 2,
    /// bottom field only
    BOTTOM        = 3,
    /// both fields interlaced
    INTERLACED    = 4,
    /// both fields sequential into one
    /// buffer, top-bottom order
    SEQ_TB        = 5,
    /// same as above + bottom-top order
    SEQ_BT        = 6,
    /// both fields alternating into
    /// separate buffers
    ALTERNATE     = 7,
    /// both fields interlaced, top field
    /// first and the top field is
    /// transmitted first
    INTERLACED_TB = 8,
    /// both fields interlaced, top field
    /// first and the bottom field is
    /// transmitted first
    INTERLACED_BT = 9,

    /// V4L2_FIELD_HAS_TOP
    pub inline fn hasTop(field: Field) bool {
        return switch (field) {
            .TOP, .INTERLACED, .INTERLACED_TB, .INTERLACED_BT, .SEQ_TB, .SEQ_BT => true,
            else => false,
        };
    }

    /// V4L2_FIELD_HAS_BOTTOM
    pub inline fn hasBottom(field: Field) bool {
        return switch (field) {
            .BOTTOM, .INTERLACED, .INTERLACED_TB, .INTERLACED_BT, .SEQ_TB, .SEQ_BT => true,
            else => false,
        };
    }

    /// V4L2_FIELD_HAS_BOTH
    pub inline fn hasBoth(field: Field) bool {
        return switch (field) {
            .INTERLACED, .INTERLACED_TB, .INTERLACED_BT, .SEQ_TB, .SEQ_BT => true,
            else => false,
        };
    }

    /// V4L2_FIELD_HAS_T_OR_B
    pub inline fn hasTopOrBottom(field: Field) bool {
        return switch (field) {
            .BOTTOM, .TOP, .ALTERNATE => true,
            else => false,
        };
    }

    /// V4L2_FIELD_IS_INTERLACED
    pub inline fn isInterlaced(field: Field) bool {
        return switch (field) {
            .INTERLACED, .INTERLACED_TB, .INTERLACED_BT => true,
            else => false,
        };
    }

    /// V4L2_FIELD_IS_SEQUENTIAL
    pub inline fn isSequential(field: Field) bool {
        return switch (field) {
            .SEQ_TB, .SEQ_BT => true,
            else => false,
        };
    }
};

/// v4l2_buf_type
pub const BufType = extern enum(u32) {
    VIDEO_CAPTURE        = 1,
    VIDEO_OUTPUT         = 2,
    VIDEO_OVERLAY        = 3,
    VBI_CAPTURE          = 4,
    VBI_OUTPUT           = 5,
    SLICED_VBI_CAPTURE   = 6,
    SLICED_VBI_OUTPUT    = 7,
    VIDEO_OUTPUT_OVERLAY = 8,
    VIDEO_CAPTURE_MPLANE = 9,
    VIDEO_OUTPUT_MPLANE  = 10,
    SDR_CAPTURE          = 11,
    SDR_OUTPUT           = 12,
    META_CAPTURE         = 13,
    META_OUTPUT          = 14,
    /// Deprecated, do not use
    PRIVATE              = 0x80,

    /// V4L2_TYPE_IS_MULTIPLANAR
    pub inline fn isMultiPlanar(Type: type) bool {
        return switch (Type) {
            .VIDEO_CAPTURE_MPLANE, .VIDEO_OUTPUT_MPLANE => true,
            else => false,
        };
    }

    /// V4L2_TYPE_IS_OUTPUT
    pub inline fn isOutput(Type: type) bool {
        return switch (Type) {
        .VIDEO_OUTPUT          ,
        .VIDEO_OUTPUT_MPLANE   ,
        .VIDEO_OVERLAY         ,
        .VIDEO_OUTPUT_OVERLAY  ,
        .VBI_OUTPUT            ,
        .SLICED_VBI_OUTPUT     ,
        .SDR_OUTPUT            ,
        .META_OUTPUT    => true,
            else => true,
        };
    }
};

/// v4l2_tunner_type
pub const TunerType = extern enum(u32) {
    RADIO             = 1,
    ANALOG_TV         = 2,
    DIGITAL_TV        = 3,
    SDR               = 4,
    RF                = 5,
    /// Deprecated, do not use
    ADC               = .SDR,
};

/// v4l2_memory
pub const Memory = extern enum(u32) {
    MMAP             = 1,
    USERPTR          = 2,
    OVERLAY          = 3,
    DMABUF           = 4,
};

/// v4l2_colorspace
///
/// see also http://vektor.theorem.ca/graphics/ycbcr/
pub const Colorspace = extern enum(u32) {

        /// Default colorspace, i.e. let the driver figure it out.
        /// Can only be used with video capture.
        DEFAULT       = 0,

        /// SMPTE 170M: used for broadcast NTSC/PAL SDTV
        SMPTE170M     = 1,

        /// Obsolete pre-1998 SMPTE 240M HDTV standard, superseded by Rec 709
        SMPTE240M     = 2,

        /// Rec.709: used for HDTV
        REC709        = 3,

        /// Deprecated, do not use. No driver will ever return this. This was
        /// based on a misunderstanding of the bt878 datasheet.
        BT878         = 4,

        /// NTSC 1953 colorspace. This only makes sense when dealing with
        /// really, really old NTSC recordings. Superseded by SMPTE 170M.
        @"470_SYSTEM_M"  = 5,

        /// EBU Tech 3213 PAL/SECAM colorspace. This only makes sense when
        /// dealing with really old PAL/SECAM recordings. Superseded by
        /// SMPTE 170M.
        @"470_SYSTEM_BG" = 6,

        /// Effectively shorthand for V4L2_COLORSPACE_SRGB, V4L2_YCBCR_ENC_601
        /// and V4L2_QUANTIZATION_FULL_RANGE. To be used for (Motion-)JPEG.
        JPEG          = 7,

        /// For RGB colorspaces such as produces by most webcams.
        SRGB          = 8,

        /// opRGB colorspace
        OPRGB         = 9,

        /// BT.2020 colorspace, used for UHDTV.
        BT2020        = 10,

        /// Raw colorspace: for RAW unprocessed images
        RAW           = 11,

        /// DCI-P3 colorspace, used by cinema projectors
        DCI_P3        = 12,

        /// V4L2_MAP_COLORSPACE_DEFAULT
        ///
        /// Determine how COLORSPACE_DEFAULT should map to a proper colorspace.
        /// This depends on whether this is a SDTV image (use SMPTE 170M), an
        /// HDTV image (use Rec. 709), or something else (use sRGB).
        pub inline fn mapColorspaceDefault(is_sdtv: bool, is_hdtv: bool) Colorspace {
            return if (is_sdtv) .SMPTE170M else if (is_hdtv) .REC709 else .SRGB;
        }
};

/// v4l2_xfer_func
pub const XferFunc = extern enum(u32) {

        /// Mapping of V4L2_XFER_FUNC_DEFAULT to actual transfer functions
        /// for the various colorspaces:
        ///
        /// V4L2_COLORSPACE_SMPTE170M, V4L2_COLORSPACE_470_SYSTEM_M,
        /// V4L2_COLORSPACE_470_SYSTEM_BG, V4L2_COLORSPACE_REC709 and
        /// V4L2_COLORSPACE_BT2020: V4L2_XFER_FUNC_709
        ///
        /// V4L2_COLORSPACE_SRGB, V4L2_COLORSPACE_JPEG: V4L2_XFER_FUNC_SRGB
        ///
        /// V4L2_COLORSPACE_OPRGB: V4L2_XFER_FUNC_OPRGB
        ///
        /// V4L2_COLORSPACE_SMPTE240M: V4L2_XFER_FUNC_SMPTE240M
        ///
        /// V4L2_COLORSPACE_RAW: V4L2_XFER_FUNC_NONE
        ///
        /// V4L2_COLORSPACE_DCI_P3: V4L2_XFER_FUNC_DCI_P3
        DEFAULT     = 0,
        @"709"      = 1,
        SRGB        = 2,
        OPRGB       = 3,
        SMPTE240M   = 4,
        NONE        = 5,
        DCI_P3      = 6,
        SMPTE2084   = 7,

    /// V4L2_MAP_XFER_FUNC_DEFAULT
    ///
    /// Determine how XFER_FUNC_DEFAULT should map to a proper transfer function.
    /// This depends on the colorspace.
    pub inline fn mapXferFuncDefault(colsp: Colorspace) XferFunc {
        return switch (colsp) {
            Colorspace.OPRGB => XferFunc.OPRGB,
            Colorspace.SMPTE240M => XferFunc.SMPTE240M,
            Colorspace.DCI_P3 => XferFunc.DCI_P3 ,
            Colorspace.RAW => XferFunc.NONE ,
            Colorspace.SRGB, Colorspace.JPEG => XferFunc.SRGB ,
            else => XferFunc.@"709",
        };
    }
};


/// v4l2_ycbcr_encoding
pub const YCbCrEncoding = extern enum(u32) {

        /// Mapping of V4L2_YCBCR_ENC_DEFAULT to actual encodings for the
        /// various colorspaces:
        ///
        /// V4L2_COLORSPACE_SMPTE170M, V4L2_COLORSPACE_470_SYSTEM_M,
        /// V4L2_COLORSPACE_470_SYSTEM_BG, V4L2_COLORSPACE_SRGB,
        /// V4L2_COLORSPACE_OPRGB and V4L2_COLORSPACE_JPEG: V4L2_YCBCR_ENC_601
        ///
        /// V4L2_COLORSPACE_REC709 and V4L2_COLORSPACE_DCI_P3: V4L2_YCBCR_ENC_709
        ///
        /// V4L2_COLORSPACE_BT2020: V4L2_YCBCR_ENC_BT2020
        ///
        /// V4L2_COLORSPACE_SMPTE240M: V4L2_YCBCR_ENC_SMPTE240M
        DEFAULT        = 0,

        /// ITU-R 601 -- SDTV
        @"601"            = 1,

        /// Rec. 709 -- HDTV
        @"709"            = 2,

        /// ITU-R 601/EN 61966-2-4 Extended Gamut -- SDTV
        XV601          = 3,

        /// Rec. 709/EN 61966-2-4 Extended Gamut -- HDTV
        XV709          = 4,

        /// sYCC (Y'CbCr encoding of sRGB), identical to ENC_601. It was added
        /// originally due to a misunderstanding of the sYCC standard. It should
        /// not be used, instead use V4L2_YCBCR_ENC_601.
        SYCC           = 5,

        /// BT.2020 Non-constant Luminance Y'CbCr
        BT2020         = 6,

        /// BT.2020 Constant Luminance Y'CbcCrc
        BT2020_CONST_LUM = 7,

        /// SMPTE 240M -- Obsolete HDTV
        SMPTE240M      = 8,

    /// V4L2_MAP_YCBCR_ENC_DEFAULT
    ///
    /// Determine how YCBCR_ENC_DEFAULT should map to a proper Y'CbCr encoding.
    /// This depends on the colorspace.
    pub inline fn mapYCbCrEncodingDefault(colsp: Colorspace) YCbCrEncoding {
        return switch (colsp) {
            .REC709 , .DCI_P3 => .@"709",
            .BT2020 => .BT2020,
            .SMPTE240M => .SMPTE240M,
            else => .@"601",
        };
    }
};

/// v4l2_hsv_encoding
///
/// enum v4l2_hsv_encoding values should not collide with the ones from
/// enum v4l2_ycbcr_encoding.
pub const HSVEncoding = extern enum(u32) {
        /// Hue mapped to 0 - 179
        @"180"                = 128,

        /// Hue mapped to 0-255
        @"256"                = 129,
};

/// v4l2_quantization
pub const Quantization = extern enum(u32) {

        /// The default for R'G'B' quantization is always full range, except
        /// for the BT2020 colorspace. For Y'CbCr the quantization is always
        /// limited range, except for COLORSPACE_JPEG: this is full range.
        DEFAULT     = 0,
        FULL_RANGE  = 1,
        LIM_RANGE   = 2,

    /// V4L2_MAP_QUANTIZATION_DEFAULT
    ///
    /// Determine how QUANTIZATION_DEFAULT should map to a proper quantization.
    /// This depends on whether the image is RGB or not, the colorspace and the
    /// Y'CbCr encoding.
    pub inline fn mapQuantizationDefault(is_rgb_or_hsv: bool, colsp: Colorspace, ycbcr_enc: YCbCrEncoding) Quantization {
        return if (is_rgb_or_hsv and colsp == .BT2020) .LIM_RANGE else if (is_rgb_or_hsv or colsp == .JPEG) .FULL_RANGE else .LIM_RANGE;
    }
};

/// v4l2_priority
pub const Priority = extern enum {
        UNSET       = 0,  // not initialized
        BACKGROUND  = 1,
        INTERACTIVE = 2,
        RECORD      = 3,
        DEFAULT     = .INTERACTIVE,
};

/// v4l2_rect
pub const Rect = extern struct {
     left: i32,
     top: i32,
     width: i32,
     height: i32,
};

/// v4l2_fract
pub const Fract = extern struct {
         numerator: u32,
         denominator: u32,
};

/// struct v4l2_capability - Describes V4L2 device caps returned by VIDIOC_QUERYCAP
///
/// @driver:       name of the driver module (e.g. "bttv")
/// @card:         name of the card (e.g. "Hauppauge WinTV")
/// @bus_info:     name of the bus (e.g. "PCI:" + pci_name(pci_dev) )
/// @version:      KERNEL_VERSION
/// @capabilities: capabilities of the physical device as a whole
/// @device_caps:  capabilities accessed via this particular device (node)
/// @reserved:     reserved fields for future extensions
pub const Capability = extern struct {
        driver:  [16]u8,
        card:    [32]u8    ,
        bus_info:[32]u8 ,
        version:     u32,
        capabilities: extern enum (u32) {
            VIDEO_CAPTURE          = 0x00000001,  // Is a video capture device
            VIDEO_OUTPUT           = 0x00000002,  // Is a video output device
            VIDEO_OVERLAY          = 0x00000004,  // Can do video overlay
            VBI_CAPTURE            = 0x00000010,  // Is a raw VBI capture device
            VBI_OUTPUT             = 0x00000020,  // Is a raw VBI output device
            SLICED_VBI_CAPTURE     = 0x00000040,  // Is a sliced VBI capture device
            SLICED_VBI_OUTPUT      = 0x00000080,  // Is a sliced VBI output device
            RDS_CAPTURE            = 0x00000100,  // RDS data capture
            VIDEO_OUTPUT_OVERLAY   = 0x00000200,  // Can do video output overlay
            HW_FREQ_SEEK           = 0x00000400,  // Can do hardware frequency seek
            RDS_OUTPUT             = 0x00000800,  // Is an RDS encoder

            /// Is a video capture device that supports multiplanar formats
            VIDEO_CAPTURE_MPLANE   = 0x00001000,
            /// Is a video output device that supports multiplanar formats
            VIDEO_OUTPUT_MPLANE    = 0x00002000,
            /// Is a video mem-to-mem device that supports multiplanar formats
            VIDEO_M2M_MPLANE       = 0x00004000,
            /// Is a video mem-to-mem device
            VIDEO_M2M              = 0x00008000,

            TUNER                  = 0x00010000,  // has a tuner
            AUDIO                  = 0x00020000,  // has audio support
            RADIO                  = 0x00040000,  // is a radio device
            MODULATOR              = 0x00080000,  // has a modulator

            SDR_CAPTURE            = 0x00100000,  // Is a SDR capture device
            EXT_PIX_FORMAT         = 0x00200000,  // Supports the extended pixel format
            SDR_OUTPUT             = 0x00400000,  // Is a SDR output device
            META_CAPTURE           = 0x00800000,  // Is a metadata capture device

            READWRITE              = 0x01000000,  // reawrite systemcalls */
            ASYNCIO                = 0x02000000,  // async O */
            STREAMING              = 0x04000000,  // streaming O ioctls */
            META_OUTPUT            = 0x08000000,  // Is a metadata output device

            TOUCH                  = 0x10000000,  // Is a touch device

            DEVICE_CAPS            = 0x80000000,  // sets device capabilities field
        },
        device_caps: u32,
        reserved: [3]u32,
};

// ------------------------------------------- //
//     V I D E O   I M A G E   F O R M A T     //
// ------------------------------------------- //

/// v4l2_pix_format
pub const PixFormat = extern struct {
    width: u32,
    height: u32,
    pixelformat: u32,
    field: Field,
    bytesperline: u32, // for padding, zero if unused
    sizeimage: u32,
    colorspace: Colorspace,
    priv: u32,  // private data, depends on pixelformat
    flags: u32, // format flags (V4L2_PIX_FMT_FLAG_*)
    _enc: extern union {
        ycbcr_enc: YCbCrEncoding,
        hsv_enc: HSVEncoding,
    },
    quantization: Quantization,
    xfer_func: XferFunc,

    /// V4L2_PIX_FMT_PRIV_MAGIC
    /// priv field value to indicates that subsequent fields are valid.
    pub const PRIV_MAGIC: u32         = 0xfeedcafe;

    /// V4L2_PIX_FMT_FLAG_*
    pub const Flags = struct {
        pub const PREMUL_ALPHA  :u32 = 0x00000001;
    };
};

        // RGB formats
        pub const PIX_FMT_RGB332  :u32 = v4l2_fourcc('R', 'G', 'B', '1'); //  8  RGB-3-3-2
        pub const PIX_FMT_RGB444  :u32 = v4l2_fourcc('R', '4', '4', '4'); // 16  xxxxrrrr ggggbbbb
        pub const PIX_FMT_ARGB444 :u32 = v4l2_fourcc('A', 'R', '1', '2'); // 16  aaaarrrr ggggbbbb
        pub const PIX_FMT_XRGB444 :u32 = v4l2_fourcc('X', 'R', '1', '2'); // 16  xxxxrrrr ggggbbbb
        pub const PIX_FMT_RGBA444 :u32 = v4l2_fourcc('R', 'A', '1', '2'); // 16  rrrrgggg bbbbaaaa
        pub const PIX_FMT_RGBX444 :u32 = v4l2_fourcc('R', 'X', '1', '2'); // 16  rrrrgggg bbbbxxxx
        pub const PIX_FMT_ABGR444 :u32 = v4l2_fourcc('A', 'B', '1', '2'); // 16  aaaabbbb ggggrrrr
        pub const PIX_FMT_XBGR444 :u32 = v4l2_fourcc('X', 'B', '1', '2'); // 16  xxxxbbbb ggggrrrr

        // Originally this had 'BA12' as fourcc, but this clashed with the older
        // V4L2_PIX_FMT_SGRBG12 which inexplicably used that same fourcc.
        // So use 'GA12' instead for V4L2_PIX_FMT_BGRA444.
        pub const PIX_FMT_BGRA444 :u32 = v4l2_fourcc('G', 'A', '1', '2'); // 16  bbbbgggg rrrraaaa
        pub const PIX_FMT_BGRX444 :u32 = v4l2_fourcc('B', 'X', '1', '2'); // 16  bbbbgggg rrrrxxxx
        pub const PIX_FMT_RGB555  :u32 = v4l2_fourcc('R', 'G', 'B', 'O'); // 16  RGB-5-5-5
        pub const PIX_FMT_ARGB555 :u32 = v4l2_fourcc('A', 'R', '1', '5'); // 16  ARGB-1-5-5-5
        pub const PIX_FMT_XRGB555 :u32 = v4l2_fourcc('X', 'R', '1', '5'); // 16  XRGB-1-5-5-5
        pub const PIX_FMT_RGBA555 :u32 = v4l2_fourcc('R', 'A', '1', '5'); // 16  RGBA-5-5-5-1
        pub const PIX_FMT_RGBX555 :u32 = v4l2_fourcc('R', 'X', '1', '5'); // 16  RGBX-5-5-5-1
        pub const PIX_FMT_ABGR555 :u32 = v4l2_fourcc('A', 'B', '1', '5'); // 16  ABGR-1-5-5-5
        pub const PIX_FMT_XBGR555 :u32 = v4l2_fourcc('X', 'B', '1', '5'); // 16  XBGR-1-5-5-5
        pub const PIX_FMT_BGRA555 :u32 = v4l2_fourcc('B', 'A', '1', '5'); // 16  BGRA-5-5-5-1
        pub const PIX_FMT_BGRX555 :u32 = v4l2_fourcc('B', 'X', '1', '5'); // 16  BGRX-5-5-5-1
        pub const PIX_FMT_RGB565  :u32 = v4l2_fourcc('R', 'G', 'B', 'P'); // 16  RGB-5-6-5
        pub const PIX_FMT_RGB555X :u32 = v4l2_fourcc('R', 'G', 'B', 'Q'); // 16  RGB-5-5-5 BE
        pub const PIX_FMT_ARGB555X :u32 = v4l2_fourcc_be('A', 'R', '1', '5'); // 16  ARGB-5-5-5 BE
        pub const PIX_FMT_XRGB555X :u32 = v4l2_fourcc_be('X', 'R', '1', '5'); // 16  XRGB-5-5-5 BE
        pub const PIX_FMT_RGB565X :u32 = v4l2_fourcc('R', 'G', 'B', 'R'); // 16  RGB-5-6-5 BE
        pub const PIX_FMT_BGR666  :u32 = v4l2_fourcc('B', 'G', 'R', 'H'); // 18  BGR-6-6-6
        pub const PIX_FMT_BGR24   :u32 = v4l2_fourcc('B', 'G', 'R', '3'); // 24  BGR-8-8-8
        pub const PIX_FMT_RGB24   :u32 = v4l2_fourcc('R', 'G', 'B', '3'); // 24  RGB-8-8-8
        pub const PIX_FMT_BGR32   :u32 = v4l2_fourcc('B', 'G', 'R', '4'); // 32  BGR-8-8-8-8
        pub const PIX_FMT_ABGR32  :u32 = v4l2_fourcc('A', 'R', '2', '4'); // 32  BGRA-8-8-8-8
        pub const PIX_FMT_XBGR32  :u32 = v4l2_fourcc('X', 'R', '2', '4'); // 32  BGRX-8-8-8-8
        pub const PIX_FMT_BGRA32  :u32 = v4l2_fourcc('R', 'A', '2', '4'); // 32  ABGR-8-8-8-8
        pub const PIX_FMT_BGRX32  :u32 = v4l2_fourcc('R', 'X', '2', '4'); // 32  XBGR-8-8-8-8
        pub const PIX_FMT_RGB32   :u32 = v4l2_fourcc('R', 'G', 'B', '4'); // 32  RGB-8-8-8-8
        pub const PIX_FMT_RGBA32  :u32 = v4l2_fourcc('A', 'B', '2', '4'); // 32  RGBA-8-8-8-8
        pub const PIX_FMT_RGBX32  :u32 = v4l2_fourcc('X', 'B', '2', '4'); // 32  RGBX-8-8-8-8
        pub const PIX_FMT_ARGB32  :u32 = v4l2_fourcc('B', 'A', '2', '4'); // 32  ARGB-8-8-8-8
        pub const PIX_FMT_XRGB32  :u32 = v4l2_fourcc('B', 'X', '2', '4'); // 32  XRGB-8-8-8-8

        // Grey formats
        pub const PIX_FMT_GREY    :u32 = v4l2_fourcc('G', 'R', 'E', 'Y'); //  8  Greyscale
        pub const PIX_FMT_Y4      :u32 = v4l2_fourcc('Y', '0', '4', ' '); //  4  Greyscale
        pub const PIX_FMT_Y6      :u32 = v4l2_fourcc('Y', '0', '6', ' '); //  6  Greyscale
        pub const PIX_FMT_Y10     :u32 = v4l2_fourcc('Y', '1', '0', ' '); // 10  Greyscale
        pub const PIX_FMT_Y12     :u32 = v4l2_fourcc('Y', '1', '2', ' '); // 12  Greyscale
        pub const PIX_FMT_Y16     :u32 = v4l2_fourcc('Y', '1', '6', ' '); // 16  Greyscale
        pub const PIX_FMT_Y16_BE  :u32 = v4l2_fourcc_be('Y', '1', '6', ' '); // 16  Greyscale BE

        // Grey bit-packed formats
        pub const PIX_FMT_Y10BPACK    :u32 = v4l2_fourcc('Y', '1', '0', 'B');  // 10  Greyscale bit-packed
        pub const PIX_FMT_Y10P     :u32 = v4l2_fourcc('Y', '1', '0', 'P'); // 10  Greyscale, MIPI RAW10 packed

        // Palette formats
        pub const PIX_FMT_PAL8 :u32 =    v4l2_fourcc('P', 'A', 'L', '8'); //  8  8-bit palette

        // Chrominance formats
        pub const PIX_FMT_UV8     :u32 = v4l2_fourcc('U', 'V', '8', ' '); //  8  UV 4:4

        // Luminance+Chrominance formats
        pub const PIF_FMT_YUYV    :u32 = v4l2_fourcc('Y', 'U', 'Y', 'V'); // 16  YUV 4:2:2
        pub const PIF_FMT_YYUV    :u32 = v4l2_fourcc('Y', 'Y', 'U', 'V'); // 16  YUV 4:2:2
        pub const PIF_FMT_YVYU    :u32 = v4l2_fourcc('Y', 'V', 'Y', 'U'); // 16 YVU 4:2:2
        pub const PIF_FMT_UYVY    :u32 = v4l2_fourcc('U', 'Y', 'V', 'Y'); // 16  YUV 4:2:2
        pub const PIF_FMT_VYUY    :u32 = v4l2_fourcc('V', 'Y', 'U', 'Y'); // 16  YUV 4:2:2
        pub const PIF_FMT_Y41P    :u32 = v4l2_fourcc('Y', '4', '1', 'P'); // 12  YUV 4:1:1
        pub const PIF_FMT_YUV444  :u32 = v4l2_fourcc('Y', '4', '4', '4'); // 16  xxxxyyyy uuuuvvvv
        pub const PIF_FMT_YUV555  :u32 = v4l2_fourcc('Y', 'U', 'V', 'O'); // 16  YUV-5-5-5
        pub const PIF_FMT_YUV565  :u32 = v4l2_fourcc('Y', 'U', 'V', 'P'); // 16  YUV-5-6-5
        pub const PIF_FMT_YUV32   :u32 = v4l2_fourcc('Y', 'U', 'V', '4'); // 32  YUV-8-8-8-8
        pub const PIF_FMT_AYUV32  :u32 = v4l2_fourcc('A', 'Y', 'U', 'V'); // 32  AYUV-8-8-8-8
        pub const PIF_FMT_XYUV32  :u32 = v4l2_fourcc('X', 'Y', 'U', 'V'); // 32  XYUV-8-8-8-8
        pub const PIF_FMT_VUYA32  :u32 = v4l2_fourcc('V', 'U', 'Y', 'A'); // 32  VUYA-8-8-8-8
        pub const PIF_FMT_VUYX32  :u32 = v4l2_fourcc('V', 'U', 'Y', 'X'); // 32  VUYX-8-8-8-8
        pub const PIF_FMT_HI240   :u32 = v4l2_fourcc('H', 'I', '2', '4'); //  8  8-bit color
        pub const PIF_FMT_HM12    :u32 = v4l2_fourcc('H', 'M', '1', '2'); //  8  YUV 4:2:0 16x16 macroblocks
        pub const PIF_FMT_M420    :u32 = v4l2_fourcc('M', '4', '2', '0'); // 12  YUV 4:2:0 2 lines y, 1 line uv interleaved

        // two planes -- one Y, one Cr + Cb interleaved
        pub const PIX_FMT_NV12    :u32 = v4l2_fourcc('N', 'V', '1', '2'); // 12  Y/CbCr 4:2:0
        pub const PIX_FMT_NV21    :u32 = v4l2_fourcc('N', 'V', '2', '1'); // 12  Y/CrCb 4:2:0
        pub const PIX_FMT_NV16    :u32 = v4l2_fourcc('N', 'V', '1', '6'); // 16  Y/CbCr 4:2:2
        pub const PIX_FMT_NV61    :u32 = v4l2_fourcc('N', 'V', '6', '1'); // 16  Y/CrCb 4:2:2
        pub const PIX_FMT_NV24    :u32 = v4l2_fourcc('N', 'V', '2', '4'); // 24  Y/CbCr 4:4:4
        pub const PIX_FMT_NV42    :u32 = v4l2_fourcc('N', 'V', '4', '2'); // 24  Y/CrCb 4:4:4

        // two non contiguous planes - one Y, one Cr + Cb interleaved
        pub const PIX_FMT_NV12M   :u32 = v4l2_fourcc('N', 'M', '1', '2'); // 12  Y/CbCr 4:2:0
        pub const PIX_FMT_NV21M   :u32 = v4l2_fourcc('N', 'M', '2', '1'); // 21  Y/CrCb 4:2:0
        pub const PIX_FMT_NV16M   :u32 = v4l2_fourcc('N', 'M', '1', '6'); // 16  Y/CbCr 4:2:2
        pub const PIX_FMT_NV61M   :u32 = v4l2_fourcc('N', 'M', '6', '1'); // 16  Y/CrCb 4:2:2
        pub const PIX_FMT_NV12MT  :u32 = v4l2_fourcc('T', 'M', '1', '2'); // 12  Y/CbCr 4:2:0 64x32 macroblocks
        pub const PIX_FMT_NV12MT_16X16 :u32 = v4l2_fourcc('V', 'M', '1', '2'); // 12  Y/CbCr 4:2:0 16x16 macroblocks

        // three planes - Y Cb, Cr
        pub const PIX_FMT_YUV410  :u32 = v4l2_fourcc('Y', 'U', 'V', '9'); //  9  YUV 4:1:0
        pub const PIX_FMT_YVU410  :u32 = v4l2_fourcc('Y', 'V', 'U', '9'); //  9  YVU 4:1:0
        pub const PIX_FMT_YUV411P :u32 = v4l2_fourcc('4', '1', '1', 'P'); // 12  YVU411 planar
        pub const PIX_FMT_YUV420  :u32 = v4l2_fourcc('Y', 'U', '1', '2'); // 12  YUV 4:2:0
        pub const PIX_FMT_YVU420  :u32 = v4l2_fourcc('Y', 'V', '1', '2'); // 12  YVU 4:2:0
        pub const PIX_FMT_YUV422P :u32 = v4l2_fourcc('4', '2', '2', 'P'); // 16  YVU422 planar

        // three non contiguous planes - Y, Cb, Cr
        pub const PIX_FMT_YUV420M :u32 = v4l2_fourcc('Y', 'M', '1', '2'); // 12  YUV420 planar
        pub const PIX_FMT_YVU420M :u32 = v4l2_fourcc('Y', 'M', '2', '1'); // 12  YVU420 planar
        pub const PIX_FMT_YUV422M :u32 = v4l2_fourcc('Y', 'M', '1', '6'); // 16  YUV422 planar
        pub const PIX_FMT_YVU422M :u32 = v4l2_fourcc('Y', 'M', '6', '1'); // 16  YVU422 planar
        pub const PIX_FMT_YUV444M :u32 = v4l2_fourcc('Y', 'M', '2', '4'); // 24  YUV444 planar
        pub const PIX_FMT_YVU444M :u32 = v4l2_fourcc('Y', 'M', '4', '2'); // 24  YVU444 planar

        // Bayer formats - see http://www.siliconimaging.com/RGB%20Bayer.htm
        pub const PIX_FMT_SBGGR8  :u32 = v4l2_fourcc('B', 'A', '8', '1'); //  8  BGBG.. GRGR..
        pub const PIX_FMT_SGBRG8  :u32 = v4l2_fourcc('G', 'B', 'R', 'G'); //  8  GBGB.. RGRG..
        pub const PIX_FMT_SGRBG8  :u32 = v4l2_fourcc('G', 'R', 'B', 'G'); //  8  GRGR.. BGBG..
        pub const PIX_FMT_SRGGB8  :u32 = v4l2_fourcc('R', 'G', 'G', 'B'); //  8  RGRG.. GBGB..
        pub const PIX_FMT_SBGGR10 :u32 = v4l2_fourcc('B', 'G', '1', '0'); // 10  BGBG.. GRGR..
        pub const PIX_FMT_SGBRG10 :u32 = v4l2_fourcc('G', 'B', '1', '0'); // 10  GBGB.. RGRG..
        pub const PIX_FMT_SGRBG10 :u32 = v4l2_fourcc('B', 'A', '1', '0'); // 10  GRGR.. BGBG..
        pub const PIX_FMT_SRGGB10 :u32 = v4l2_fourcc('R', 'G', '1', '0'); // 10  RGRG.. GBGB..
        // 10bit raw bayer = packed, 5 bytes for every 4 pixels */
        pub const PIX_FMT_SBGGR10P :u32 = v4l2_fourcc('p', 'B', 'A', 'A');
        pub const PIX_FMT_SGBRG10P :u32 = v4l2_fourcc('p', 'G', 'A', 'A');
        pub const PIX_FMT_SGRBG10P :u32 = v4l2_fourcc('p', 'g', 'A', 'A');
        pub const PIX_FMT_SRGGB10P :u32 = v4l2_fourcc('p', 'R', 'A', 'A');
        // 10bit raw bayer = a-law compressed to 8 bits */
        pub const PIX_FMT_SBGGR10ALAW8 :u32 = v4l2_fourcc('a', 'B', 'A', '8');
        pub const PIX_FMT_SGBRG10ALAW8 :u32 = v4l2_fourcc('a', 'G', 'A', '8');
        pub const PIX_FMT_SGRBG10ALAW8 :u32 = v4l2_fourcc('a', 'g', 'A', '8');
        pub const PIX_FMT_SRGGB10ALAW8 :u32 = v4l2_fourcc('a', 'R', 'A', '8');
        // 10bit raw bayer = DPCM compressed to 8 bits */
        pub const PIX_FMT_SBGGR10DPCM8 :u32 = v4l2_fourcc('b', 'B', 'A', '8');
        pub const PIX_FMT_SGBRG10DPCM8 :u32 = v4l2_fourcc('b', 'G', 'A', '8');
        pub const PIX_FMT_SGRBG10DPCM8 :u32 = v4l2_fourcc('B', 'D', '1', '0');
        pub const PIX_FMT_SRGGB10DPCM8 :u32 = v4l2_fourcc('b', 'R', 'A', '8');
        pub const PIX_FMT_SBGGR12 :u32 = v4l2_fourcc('B', 'G', '1', '2'); // 12  BGBG.. GRGR..
        pub const PIX_FMT_SGBRG12 :u32 = v4l2_fourcc('G', 'B', '1', '2'); // 12  GBGB.. RGRG..
        pub const PIX_FMT_SGRBG12 :u32 = v4l2_fourcc('B', 'A', '1', '2'); // 12  GRGR.. BGBG..
        pub const PIX_FMT_SRGGB12 :u32 = v4l2_fourcc('R', 'G', '1', '2'); // 12  RGRG.. GBGB..
        // 12bit raw bayer = packed, 6 bytes for every 4 pixels */
        pub const PIX_FMT_SBGGR12P :u32 = v4l2_fourcc('p', 'B', 'C', 'C');
        pub const PIX_FMT_SGBRG12P :u32 = v4l2_fourcc('p', 'G', 'C', 'C');
        pub const PIX_FMT_SGRBG12P :u32 = v4l2_fourcc('p', 'g', 'C', 'C');
        pub const PIX_FMT_SRGGB12P :u32 = v4l2_fourcc('p', 'R', 'C', 'C');
        // 14bit raw bayer = packed, 7 bytes for every 4 pixels */
        pub const PIX_FMT_SBGGR14P :u32 = v4l2_fourcc('p', 'B', 'E', 'E');
        pub const PIX_FMT_SGBRG14P :u32 = v4l2_fourcc('p', 'G', 'E', 'E');
        pub const PIX_FMT_SGRBG14P :u32 = v4l2_fourcc('p', 'g', 'E', 'E');
        pub const PIX_FMT_SRGGB14P :u32 = v4l2_fourcc('p', 'R', 'E', 'E');
        pub const PIX_FMT_SBGGR16 :u32 = v4l2_fourcc('B', 'Y', 'R', '2'); // 16  BGBG.. GRGR..
        pub const PIX_FMT_SGBRG16 :u32 = v4l2_fourcc('G', 'B', '1', '6'); // 16  GBGB.. RGRG..
        pub const PIX_FMT_SGRBG16 :u32 = v4l2_fourcc('G', 'R', '1', '6'); // 16  GRGR.. BGBG..
        pub const PIX_FMT_SRGGB16 :u32 = v4l2_fourcc('R', 'G', '1', '6'); // 16  RGRG.. GBGB..

        // HSV formats
        pub const PIX_FMT_HSV24 :u32 = v4l2_fourcc('H', 'S', 'V', '3');
        pub const PIX_FMT_HSV32 :u32 = v4l2_fourcc('H', 'S', 'V', '4');

        // compressed formats
        pub const PIX_FMT_MJPEG    :u32 = v4l2_fourcc('M', 'J', 'P', 'G'); // Motion-JPEG
        pub const PIX_FMT_JPEG     :u32 = v4l2_fourcc('J', 'P', 'E', 'G'); // JFIF JPEG
        pub const PIX_FMT_DV       :u32 = v4l2_fourcc('d', 'v', 's', 'd'); // 1394
        pub const PIX_FMT_MPEG     :u32 = v4l2_fourcc('M', 'P', 'E', 'G'); // MPEG-1/2/4 Multiplexed
        pub const PIX_FMT_H264     :u32 = v4l2_fourcc('H', '2', '6', '4'); // H264 with start codes
        pub const PIX_FMT_H264_NO_SC :u32 = v4l2_fourcc('A', 'V', 'C', '1'); // H264 without start codes
        pub const PIX_FMT_H264_MVC :u32 = v4l2_fourcc('M', '2', '6', '4'); // H264 MVC
        pub const PIX_FMT_H263     :u32 = v4l2_fourcc('H', '2', '6', '3'); // H263
        pub const PIX_FMT_MPEG1    :u32 = v4l2_fourcc('M', 'P', 'G', '1'); // MPEG-1 ES
        pub const PIX_FMT_MPEG2    :u32 = v4l2_fourcc('M', 'P', 'G', '2'); // MPEG-2 ES
        pub const PIX_FMT_MPEG2_SLICE :u32 = v4l2_fourcc('M', 'G', '2', 'S'); // MPEG-2 parsed slice data
        pub const PIX_FMT_MPEG4    :u32 = v4l2_fourcc('M', 'P', 'G', '4'); // MPEG-4 part 2 ES
        pub const PIX_FMT_XVID     :u32 = v4l2_fourcc('X', 'V', 'I', 'D'); // Xvid
        pub const PIX_FMT_VC1_ANNEX_G :u32 = v4l2_fourcc('V', 'C', '1', 'G'); // SMPTE 421M Annex G compliant stream
        pub const PIX_FMT_VC1_ANNEX_L :u32 = v4l2_fourcc('V', 'C', '1', 'L'); // SMPTE 421M Annex L compliant stream
        pub const PIX_FMT_VP8      :u32 = v4l2_fourcc('V', 'P', '8', '0'); // VP8
        pub const PIX_FMT_VP9      :u32 = v4l2_fourcc('V', 'P', '9', '0'); // VP9
        pub const PIX_FMT_HEVC     :u32 = v4l2_fourcc('H', 'E', 'V', 'C'); // HEVC aka H.265
        pub const PIX_FMT_FWHT     :u32 = v4l2_fourcc('F', 'W', 'H', 'T'); // Fast Walsh Hadamard Transform (vicodec)
        pub const PIX_FMT_FWHT_STATELESS     :u32 = v4l2_fourcc('S', 'F', 'W', 'H'); // Stateless FWHT (vicodec)

        //  Vendor-specific formats
        pub const PIX_FMT_CPIA1    :u32 = v4l2_fourcc('C', 'P', 'I', 'A'); // cpia1 YUV
        pub const PIX_FMT_WNVA     :u32 = v4l2_fourcc('W', 'N', 'V', 'A'); // Winnov hw compress
        pub const PIX_FMT_SN9C10X  :u32 = v4l2_fourcc('S', '9', '1', '0'); // SN9C10x compression
        pub const PIX_FMT_SN9C20X_I420 :u32 = v4l2_fourcc('S', '9', '2', '0'); // SN9C20x YUV 4:2:0
        pub const PIX_FMT_PWC1     :u32 = v4l2_fourcc('P', 'W', 'C', '1'); // pwc older webcam
        pub const PIX_FMT_PWC2     :u32 = v4l2_fourcc('P', 'W', 'C', '2'); // pwc newer webcam
        pub const PIX_FMT_ET61X251 :u32 = v4l2_fourcc('E', '6', '2', '5'); // ET61X251 compression
        pub const PIX_FMT_SPCA501  :u32 = v4l2_fourcc('S', '5', '0', '1'); // YUYV per line
        pub const PIX_FMT_SPCA505  :u32 = v4l2_fourcc('S', '5', '0', '5'); // YYUV per line
        pub const PIX_FMT_SPCA508  :u32 = v4l2_fourcc('S', '5', '0', '8'); // YUVY per line
        pub const PIX_FMT_SPCA561  :u32 = v4l2_fourcc('S', '5', '6', '1'); // compressed GBRG bayer
        pub const PIX_FMT_PAC207   :u32 = v4l2_fourcc('P', '2', '0', '7'); // compressed BGGR bayer
        pub const PIX_FMT_MR97310A :u32 = v4l2_fourcc('M', '3', '1', '0'); // compressed BGGR bayer
        pub const PIX_FMT_JL2005BCD :u32 = v4l2_fourcc('J', 'L', '2', '0'); // compressed RGGB bayer
        pub const PIX_FMT_SN9C2028 :u32 = v4l2_fourcc('S', 'O', 'N', 'X'); // compressed GBRG bayer
        pub const PIX_FMT_SQ905C   :u32 = v4l2_fourcc('9', '0', '5', 'C'); // compressed RGGB bayer
        pub const PIX_FMT_PJPG     :u32 = v4l2_fourcc('P', 'J', 'P', 'G'); // Pixart 73xx JPEG
        pub const PIX_FMT_OV511    :u32 = v4l2_fourcc('O', '5', '1', '1'); // ov511 JPEG
        pub const PIX_FMT_OV518    :u32 = v4l2_fourcc('O', '5', '1', '8'); // ov518 JPEG
        pub const PIX_FMT_STV0680  :u32 = v4l2_fourcc('S', '6', '8', '0'); // stv0680 bayer
        pub const PIX_FMT_TM6000   :u32 = v4l2_fourcc('T', 'M', '6', '0'); // tm5600/tm60x0
        pub const PIX_FMT_CIT_YYVYUY :u32 = v4l2_fourcc('C', 'I', 'T', 'V'); // one line of Y then 1 line of VYUY
        pub const PIX_FMT_KONICA420  :u32 = v4l2_fourcc('K', 'O', 'N', 'I'); // YUV420 planar in blocks of 256 pixels
        pub const PIX_FMT_JPGL       :u32 = v4l2_fourcc('J', 'P', 'G', 'L'); // JPEG-Lite
        pub const PIX_FMT_SE401      :u32 = v4l2_fourcc('S', '4', '0', '1'); // se401 janggu compressed rgb
        pub const PIX_FMT_S5C_UYVY_JPG :u32 = v4l2_fourcc('S', '5', 'C', 'I'); // S5C73M3 interleaved UYVY/JPEG
        pub const PIX_FMT_Y8I      :u32 = v4l2_fourcc('Y', '8', 'I', ' '); // Greyscale 8-bit L/R interleaved
        pub const PIX_FMT_Y12I     :u32 = v4l2_fourcc('Y', '1', '2', 'I'); // Greyscale 12-bit L/R interleaved
        pub const PIX_FMT_Z16      :u32 = v4l2_fourcc('Z', '1', '6', ' '); // Depth data 16-bit
        pub const PIX_FMT_MT21C    :u32 = v4l2_fourcc('M', 'T', '2', '1'); // Mediatek compressed block mode
        pub const PIX_FMT_INZI     :u32 = v4l2_fourcc('I', 'N', 'Z', 'I'); // Intel Planar Greyscale 10-bit and Depth 16-bit
        pub const PIX_FMT_SUNXI_TILED_NV12 :u32 = v4l2_fourcc('S', 'T', '1', '2'); // Sunxi Tiled NV12 Format
        pub const PIX_FMT_CNF4     :u32 = v4l2_fourcc('C', 'N', 'F', '4'); // Intel 4-bit packed depth confidence information

        // 10bit raw bayer packed, 32 bytes for every 25 pixels, last LSB 6 bits unused
        pub const PIX_FMT_IPU3_SBGGR10       :u32 = v4l2_fourcc('i', 'p', '3', 'b'); // IPU3 packed 10-bit BGGR bayer
        pub const PIX_FMT_IPU3_SGBRG10       :u32 = v4l2_fourcc('i', 'p', '3', 'g'); // IPU3 packed 10-bit GBRG bayer
        pub const PIX_FMT_IPU3_SGRBG10       :u32 = v4l2_fourcc('i', 'p', '3', 'G'); // IPU3 packed 10-bit GRBG bayer
        pub const PIX_FMT_IPU3_SRGGB10       :u32 = v4l2_fourcc('i', 'p', '3', 'r'); // IPU3 packed 10-bit RGGB bayer

    // SDR formats - used only for Software Defined Radio devices
    pub const SDR_FMT_CU8          :u32 = v4l2_fourcc('C', 'U', '0', '8'); // IQ u8
    pub const SDR_FMT_CU16LE       :u32 = v4l2_fourcc('C', 'U', '1', '6'); // IQ u16le
    pub const SDR_FMT_CS8          :u32 = v4l2_fourcc('C', 'S', '0', '8'); // complex s8
    pub const SDR_FMT_CS14LE       :u32 = v4l2_fourcc('C', 'S', '1', '4'); // complex s14le
    pub const SDR_FMT_RU12LE       :u32 = v4l2_fourcc('R', 'U', '1', '2'); // real u12le
    pub const SDR_FMT_PCU16BE      :u32 = v4l2_fourcc('P', 'C', '1', '6'); // planar complex u16be
    pub const SDR_FMT_PCU18BE      :u32 = v4l2_fourcc('P', 'C', '1', '8'); // planar complex u18be
    pub const SDR_FMT_PCU20BE      :u32 = v4l2_fourcc('P', 'C', '2', '0'); // planar complex u20be

    // Touch formats - used for Touch devices
    pub const TCH_FMT_DELTA_TD16 :u32 = v4l2_fourcc('T', 'D', '1', '6'); // 16-bit signed deltas
    pub const TCH_FMT_DELTA_TD08 :u32 = v4l2_fourcc('T', 'D', '0', '8'); // 8-bit signed deltas
    pub const TCH_FMT_TU16       :u32 = v4l2_fourcc('T', 'U', '1', '6'); // 16-bit unsigned touch data
    pub const TCH_FMT_TU08       :u32 = v4l2_fourcc('T', 'U', '0', '8'); // 8-bit unsigned touch data

    // Meta-data formats
    pub const META_FMT_VSP1_HGO    :u32 = v4l2_fourcc('V', 'S', 'P', 'H'); // R-Car VSP1 1-D Histogram
    pub const META_FMT_VSP1_HGT    :u32 = v4l2_fourcc('V', 'S', 'P', 'T'); // R-Car VSP1 2-D Histogram
    pub const META_FMT_UVC         :u32 = v4l2_fourcc('U', 'V', 'C', 'H'); // UVC Payload Header metadata
    pub const META_FMT_D4XX        :u32 = v4l2_fourcc('D', '4', 'X', 'X'); // D4XX Payload Header metadata


// ------------------------------------------- //
//     F O R M A T   E N U M E R A T I O N     //
// ------------------------------------------- //

/// v4l2_fmtdesc
pub const FmtDesc = extern struct {
    index: u32, // Format number
    type: BufType,
    flags: u32,
    description: [32]u8, // Description string
    pixelformat: u32, // Format fourcc
    reserved: [4]u32,

    pub const Flags = struct {
        pub const COMPRESSED                :u32 = 0x0001;
        pub const EMULATED                  :u32 = 0x0002;
        pub const CONTINUOUS_BYTESTREAM     :u32 = 0x0004;
        pub const DYN_RESOLUTION            :u32 = 0x0008;
    };
};


// --------------------------------------------------- //
//     F R A M E   S I Z E   E N U M E R A T I O N     //
//         Frame Size and frame rate enumeration       //
// --------------------------------------------------- //

/// v4l2_frmsizetypes
pub const FrmSizeTypes = extern enum(u32) {
    DISCRETE      = 1,
    CONTINUOUS    = 2,
    STEPWISE      = 3,
};

/// v4l2_frmsize_discrete
pub const FrmSizeDiscrete = extern struct  {
    width: u32,          // Frame width [pixel]
    height: u32,         // Frame height [pixel]
};

/// v4l2_frmsize_stepwise
pub const FrmSizeStepwise= extern struct  {
    min_width:u32,      // Minimum frame width [pixel]
    max_width:u32,      // Maximum frame width [pixel]
    step_width:u32,     // Frame width step size [pixel]
    min_height:u32,     // Minimum frame height [pixel]
    max_height:u32,     // Maximum frame height [pixel]
    step_height:u32,    // Frame height step size [pixel]
};

/// v4l2_frmsizeenum
pub const  FrmSizeEnum = extern struct  {
    index:u32,          // Frame size number
    pixel_format:u32,   // Pixel format
    type: FrmSizeTypes,        // Frame size type the device supports.
    _frmsize: extern union {                                 // Frame size
        discrete: FrmSizeDiscrete,
        stepwise: FrmSizeStepwise,
    },

    reserved: [2]u32,                    // Reserved space for future use
};

// --------------------------------------------------- //
//     F R A M E   R A T E   E N U M E R A T I O N     //
// --------------------------------------------------- //

/// v4l2_frmivaltypes
pub const FrmIvalTypes= extern enum  {
    DISCRETE      = 1,
    CONTINUOUS    = 2,
    STEPWISE      = 3,
};

/// v4l2_frmival_stepwise
pub const FrmIvalStepwise = extern struct {
    min: Fract,            // Minimum frame interval [s]
    max: Fract,            // Maximum frame interval [s]
    step: Fract,           // Frame interval step size [s]
};

/// v4l2_frmivalenum
pub const FrmIvalEnum = extern struct  {
    index: u32,          // Frame format index
    pixel_format: u32,   // Pixel format
    width: u32,          // Frame width
    height: u32,         // Frame height
    type: u32,           // Frame interval type the device supports.
    _frmival: extern union {                                 // Frame interval
        discrete: Fract,
        stepwise: FrmIvalStepwise,
    },
    reserved: [2]u32,                    // Reserved space for future use
};

// ----------------------- //
//     T I M E C O D E     //
// ----------------------- //

/// v4l2_timecode
pub const Timecode = extern struct {
        type: Type,
        flags: u32,
        frames: u8,
        seconds: u8,
        minutes: u8,
        hours: u8,
        userbits: [4]u8,

    /// V4L2_TC_TYPE_*
    pub const Type = struct {
        pub const @"24FPS" :u32 =              1;
        pub const @"25FPS" :u32 =              2;
        pub const @"30FPS" :u32 =              3;
        pub const @"50FPS" :u32 =              4;
        pub const @"60FPS" :u32 =              5;
    };

    /// V4L2_TC_*
    pub const Flags = struct {
        pub const FLAG_DROPFRAME          : u32 = 0x0001; // "drop-frame" mode
        pub const FLAG_COLORFRAME         : u32 = 0x0002;
        pub const USERBITS_field          : u32 = 0x000C;
        pub const USERBITS_USERDEFINED    : u32 = 0x0000;
        pub const USERBITS_8BITCHARS      : u32 = 0x0008;
    // The above is based on SMPTE timecodes
    };
};


/// v4l2_jpegcompression
pub const  JPEGCompression= extern struct  {
    quality: i32,

    APPn: i32,              // Number of APP segment to be written, must be 0..15
    APP_len: i32,           // Length of data in JPEG APPn segment
    APP_data: [60]u8,      // Data in the JPEG APPn segment.

    COM_len: i32,           // Length of data in JPEG COM segment
    COM_data: [60]u8,     // Data in JPEG COM segment

    jpeg_markers: u32,      // Which markers should go into the JPEG
                            // output. Unless you exactly know what
                            // you do, leave them untouched.
                            // Including less markers will make the
                            // resulting code smaller, but there will
                            // be fewer applications which can read it.
                            // The presence of the APP and COM marker
                            // is influenced by APP_len and COM_len
                            // ONLY, not by this property!

    /// V4L2_JPEG_MARKER_*
    pub const Markers = struct {
        pub const DHT: u32 = 1<<3;    // Define Huffman Tables
        pub const DQT: u32 = 1<<4;    // Define Quantization Tables
        pub const DRI: u32 = 1<<5;    // Define Restart Interval
        pub const COM: u32 = 1<<6;    // Comment segment
        pub const APP: u32 = 1<<7;    // App segment, driver will
    };

};

// --------------------------------------------------- //
//     M E M O R Y - M A P P I N G   B U F F E R S     //
// --------------------------------------------------- //

/// v4l2_requestbuffers
pub const Requestbuffers = extern struct {
        count: u32,
        type: BufType,           // enum v4l2_buf_type
        memory: Memory,         // enum v4l2_memory
        capabilities: u32,
        reserved: [1]u32,
};

/// V4L2_BUF_CAP_SUPPORTS*
///
/// capabilities for struct v4l2_requestbuffers and v4l2_create_buffers
pub const BufCap = struct {
    pub const MMAP      : u32= 1 << 0;
    pub const USERPTR   : u32= 1 << 1;
    pub const DMABUF    : u32= 1 << 2;
    pub const REQUESTS  : u32= 1 << 3;
    pub const ORPHANED_BUFS :u32 = 1 << 4;
};

/// struct v4l2_plane - plane info for multi-planar buffers
/// @bytesused:          number of bytes occupied by data in the plane (payload)
/// @length:             size of this plane (NOT the payload) in bytes
/// @mem_offset:         when memory in the associated struct v4l2_buffer is
///                      V4L2_MEMORY_MMAP, equals the offset from the start of
///                      the device memory for this plane (or is a "cookie" that
///                      should be passed to mmap() called on the video node)
/// @userptr:            when memory is V4L2_MEMORY_USERPTR, a userspace pointer
///                      pointing to this plane
/// @fd:                 when memory is V4L2_MEMORY_DMABUF, a userspace file
///                      descriptor associated with this plane
/// @data_offset:        offset in the plane to the start of data; usually 0,
///                      unless there is a header in front of the data
///
/// Multi-planar buffers consist of one or more planes, e.g. an YCbCr buffer
/// with two planes can have one plane for Y, and another for interleaved CbCr
/// components. Each plane can reside in a separate memory buffer, or even in
/// a completely separate memory node (e.g. in embedded devices).
pub const Plane = extern struct  {
    bytesused: u32,
    length: u32,
    m: extern union {
        mem_offset: u32,
        userptr: u64,
        fd: i32,
    },
    data_offset: u32,
    reserved: [11]u32,
};

/// struct v4l2_buffer - video buffer info
/// @index:      id number of the buffer
/// @type:       enum v4l2_buf_type; buffer type (type == *_MPLANE for
///              multiplanar buffers);
/// @bytesused:  number of bytes occupied by data in the buffer (payload);
///              unused (set to 0) for multiplanar buffers
/// @flags:      buffer informational flags
/// @field:      enum v4l2_field; field order of the image in the buffer
/// @timestamp:  frame timestamp
/// @timecode:   frame timecode
/// @sequence:   sequence count of this frame
/// @memory:     enum v4l2_memory; the method, in which the actual video data is
///              passed
/// @offset:     for non-multiplanar buffers with memory == V4L2_MEMORY_MMAP;
///              offset from the start of the device memory for this plane,
///              (or a "cookie" that should be passed to mmap() as offset)
/// @userptr:    for non-multiplanar buffers with memory == V4L2_MEMORY_USERPTR;
///              a userspace pointer pointing to this buffer
/// @fd:         for non-multiplanar buffers with memory == V4L2_MEMORY_DMABUF;
///              a userspace file descriptor associated with this buffer
/// @planes:     for multiplanar buffers; userspace pointer to the array of plane
///              info structs for this buffer
/// @length:     size in bytes of the buffer (NOT its payload) for single-plane
///              buffers (when type != *_MPLANE); number of elements in the
///              planes array for multi-plane buffers
/// @request_fd: fd of the request that this buffer should use
///
/// Contains data exchanged by application and driver using one of the Streaming
/// I/O methods.
pub const v4l2_buffer = extern struct {
        index: u32,
        type: u32,
        bytesused: u32,
        flags: u32,
        field: u32,
        timestamp: std.os.linux.timeval,
        timecode: Timecode,
        sequence: u32,

        // memory location
        memory: u32,
        m: extern union {
            offset: u32,
            userptr: u64,
            planes: *Plane,
            fd: i32,
        } ,
        length: u32,
        reserved2: u32,
        _u: extern union {
            request_fd: i32,
            reserved: u32,
        },

    /// V4L2_BUF_FLAG_*
    pub const Flags = struct {
        // Buffer is mapped (flag)
        pub const MAPPED                    : u32 = 0x00000001;
        // Buffer is queued for processing
        pub const QUEUED                    : u32 = 0x00000002;
        // Buffer is ready
        pub const DONE                      : u32 = 0x00000004;
        // Image is a keyframe (I-frame)
        pub const KEYFRAME                  : u32 = 0x00000008;
        // Image is a P-frame
        pub const PFRAME                    : u32 = 0x00000010;
        // Image is a B-frame
        pub const BFRAME                    : u32 = 0x00000020;
        // Buffer is ready, but the data contained within is corrupted.
        pub const ERROR                     : u32 = 0x00000040;
        // Buffer is added to an unqueued request
        pub const IN_REQUEST                : u32 = 0x00000080;
        // timecode field is valid
        pub const TIMECODE                  : u32 = 0x00000100;
        // Buffer is prepared for queuing
        pub const PREPARED                  : u32 = 0x00000400;
        // Cache handling flags
        pub const NO_CACHE_INVALIDATE       : u32 = 0x00000800;
        pub const NO_CACHE_CLEAN            : u32 = 0x00001000;
        // Timestamp type
        pub const TIMESTAMP_MASK            : u32 = 0x0000e000;
        pub const TIMESTAMP_UNKNOWN         : u32 = 0x00000000;
        pub const TIMESTAMP_MONOTONIC       : u32 = 0x00002000;
        pub const TIMESTAMP_COPY            : u32 = 0x00004000;
        // Timestamp sources.
        pub const TSTAMP_SRC_MASK           : u32 = 0x00070000;
        pub const TSTAMP_SRC_EOF            : u32 = 0x00000000;
        pub const TSTAMP_SRC_SOE            : u32 = 0x00010000;
        // mem2mem encoder/decoder
        pub const LAST                      : u32 = 0x00100000;
        // request_fd is valid
        pub const REQUEST_FD                : u32 = 0x00800000;

    };
};

/// v4l2_timeval_to_ns - Convert timeval to nanoseconds
/// @ts:         pointer to the timeval variable to be converted
///
/// Returns the scalar nanosecond representation of the timeval
/// parameter.
pub inline fn timevalTo_ns(tv: *std.os.linux.timeval) u64 {
    return tv.tv_sec * 1000000000 + tv.tv_usec * 1000;
}

/// struct v4l2_exportbuffer - export of video buffer as DMABUF file descriptor
///
/// @index:      id number of the buffer
/// @type:       enum v4l2_buf_type; buffer type (type == *_MPLANE for
///              multiplanar buffers);
/// @plane:      index of the plane to be exported, 0 for single plane queues
/// @flags:      flags for newly created file, currently only O_CLOEXEC is
///              supported, refer to manual of open syscall for more details
/// @fd:         file descriptor associated with DMABUF (set by driver)
///
/// Contains data used for exporting a video buffer as DMABUF file descriptor.
/// The buffer is identified by a 'cookie' returned by VIDIOC_QUERYBUF
/// (identical to the cookie used to mmap() the buffer to userspace). All
/// reserved fields must be set to zero. The field reserved0 is expected to
/// become a structure 'type' allowing an alternative layout of the structure
/// content. Therefore this field should not be used for any other extensions.
pub const ExportBuffer = extern struct {
    type: BufType,
    index: u32,
    plane: u32,
    flags: u32,
    fd: i32,
    reserved: [11]u32,
};

// ------------------------------------- //
//     O V E R L A Y   P R E V I E W     //
// ------------------------------------- //

/// v4l2_framebuffer
pub const FrameBuffer = extern struct {
    capability: u32,
    flags: u32,
    // FIXME: in theory we should pass something like PCI device + memory
    // region + offset instead of some physical address
    base: usize,
    fmt: extern struct {
        width: u32,
        height: u32,
        pixelformat: u32,
        field: Field,
        bytesperline: u32,   // for padding, zero if unused
        sizeimage: u32,
        colorspace: Colorspace,
        priv: u32,           // reserved field, set to 0
    },

    //  Flags for the 'capability' field. Read only
    pub const FlagsCap = struct {
        pub const EXTERNOVERLAY     : u32 = 0x0001;
        pub const CHROMAKEY         : u32 = 0x0002;
        pub const LIST_CLIPPING     : u32 = 0x0004;
        pub const BITMAP_CLIPPING   : u32 = 0x0008;
        pub const LOCAL_ALPHA       : u32 = 0x0010;
        pub const GLOBAL_ALPHA      : u32 = 0x0020;
        pub const LOCAL_INV_ALPHA   : u32 = 0x0040;
        pub const SRC_CHROMAKEY     : u32 = 0x0080;
    };

    //  Flags for the 'flags' field.
    pub const Flags = struct {
        pub const _PRIMARY          : u32 = 0x0001;
        pub const _OVERLAY          : u32 = 0x0002;
        pub const _CHROMAKEY        : u32 = 0x0004;
        pub const _LOCAL_ALPHA      : u32 = 0x0008;
        pub const _GLOBAL_ALPHA     : u32 = 0x0010;
        pub const _LOCAL_INV_ALPHA  : u32 = 0x0020;
        pub const _SRC_CHROMAKEY    : u32 = 0x0040;
    };
};

/// v4l2_clip
pub const Clip = extern struct {
    c: Rect,
    next: *Clip,
};

/// v4l2_window
pub const Window = extern struct {
    w: Rect,
    field: Field,
    chromakey: u32,
    clips: *Clip,
    clipcount: u32,
    bitmap: usize,
    global_alpha: u8,
};

// ------------------------------------------- //
//     C A P T U R E   P A R A M E T E R S     //
// ------------------------------------------- //

pub const CaptureParm = extern struct {
    capability: u32,    //  Supported modes
    capturemode: u32,   //  Current mode
    timeperframe: Fract,  //  Time per frame in seconds
    extendedmode: u32,  //  Driver-specific extensions
    readbuffers: u32,   //  # of buffers for read
    reserved: [4]u32,

    ///  Flags for 'capability' and 'capturemode' fields
    pub const Flags = struct {
        pub const MODE_HIGHQUALITY   :u32 = 0x0001;  //  High quality imaging mode
        pub const CAP_TIMEPERFRAME   :u32 = 0x1000;  //  timeperframe field is supported
    };
};

/// v4l2_outputparm
pub const OutputParm = extern struct {
    capability: u32,   //  Supported modes
    outputmode: u32,   //  Current mode
    timeperframe: Fract, //  Time per frame in seconds
    extendedmode: u32, //  Driver-specific extensions
    writebuffers: u32, //  # of buffers for write
    reserved: [4]u32,
};

// ----------------------------------------------- //
//     I N P U T   I M A G E   C R O P P I N G     //
// ----------------------------------------------- //

/// v4l2_cropcap
pub const CropCap = extern struct {
    type: BufType,
    bounds: Rect,
    defrect: Rect,
    pixelaspect: Fract,
};

/// v4l2_crop
pub const Crop = extern struct {
    type: BufType,
    c: Rect,
};

/// struct v4l2_selection - selection info
/// @type:       buffer type (do not use *_MPLANE types)
/// @target:     Selection target, used to choose one of possible rectangles;
///              defined in v4l2-common.h; V4L2_SEL_TGT_* .
/// @flags:      constraints flags, defined in v4l2-common.h; V4L2_SEL_FLAG_*.
/// @r:          coordinates of selection window
/// @reserved:   for future use, rounds structure size to 64 bytes, set to zero
///
/// Hardware may use multiple helper windows to process a video stream.
/// The structure is used to exchange this selection areas between
/// an application and a driver.
pub const  Selection = extern struct {
    type: BufType,
    target: u32,
    flags: u32,
    r: Rect,
    reserved: [9]u32,
};

// ------------------------------------------------- //
//     A N A L O G   V I D E O   S T A N D A R D     //
// ------------------------------------------------- //

pub const StdId = u64;

pub const Std = struct {

    // one bit for each
    pub const PAL_B          : StdId =  0x00000001;
    pub const PAL_B1         : StdId =  0x00000002;
    pub const PAL_G          : StdId =  0x00000004;
    pub const PAL_H          : StdId =  0x00000008;
    pub const PAL_I          : StdId =  0x00000010;
    pub const PAL_D          : StdId =  0x00000020;
    pub const PAL_D1         : StdId =  0x00000040;
    pub const PAL_K          : StdId =  0x00000080;

    pub const PAL_M          : StdId = 0x00000100;
    pub const PAL_N          : StdId = 0x00000200;
    pub const PAL_Nc         : StdId = 0x00000400;
    pub const PAL_60         : StdId = 0x00000800;

    pub const NTSC_M         : StdId = 0x00001000;       // BTSC
    pub const NTSC_M_JP      : StdId = 0x00002000;       // EIA-J
    pub const NTSC_443       : StdId = 0x00004000;
    pub const NTSC_M_KR      : StdId = 0x00008000;       // FM A2

    pub const SECAM_B        : StdId = 0x00010000;
    pub const SECAM_D        : StdId = 0x00020000;
    pub const SECAM_G        : StdId = 0x00040000;
    pub const SECAM_H        : StdId = 0x00080000;
    pub const SECAM_K        : StdId = 0x00100000;
    pub const SECAM_K1       : StdId = 0x00200000;
    pub const SECAM_L        : StdId = 0x00400000;
    pub const SECAM_LC       : StdId = 0x00800000;

    // ATSC/HDTV
    pub const ATSC_8_VSB     : StdId = 0x01000000;
    pub const ATSC_16_VSB    : StdId = 0x02000000;

    // FIXME:
    // Although std_id is 64 bits, there is an issue on PPC32 architecture that
    // makes switch(__u64) to break. So, there's a hack on v4l2-common.c rounding
    // this value to 32 bits.
    // As, currently, the max value is for V4L2_STD_ATSC_16_VSB (30 bits wide),
    // it should work fine. However, if needed to add more than two standards,
    // v4l2-common.c should be fixed.

    // Some macros to merge video standards in order to make live easier for the
    // drivers and V4L2 applications

    // "Common" NTSC/M - It should be noticed that V4L2_STD_NTSC_443 is
    // Missing here.
    pub const NTSC           : StdId = .NTSC_M | .NTSC_M_JP | .NTSC_M_KR;
    // Secam macros
    pub const SECAM_DK       : StdId = V4L2_STD_SECAM_D | V4L2_STD_SECAM_K | V4L2_STD_SECAM_K1;
    // All Secam Standards
    pub const SECAM          : StdId = V4L2_STD_SECAM_B | V4L2_STD_SECAM_G       | V4L2_STD_SECAM_H       | V4L2_STD_SECAM_DK      | V4L2_STD_SECAM_L       | V4L2_STD_SECAM_LC;
    // PAL macros
    pub const PAL_BG         : StdId = V4L2_STD_PAL_B         | V4L2_STD_PAL_B1        | V4L2_STD_PAL_G;
    pub const PAL_DK         : StdId = V4L2_STD_PAL_D         | V4L2_STD_PAL_D1        | V4L2_STD_PAL_K;

    // "Common" PAL - This macro is there to be compatible with the old
    // V4L1 concept of "PAL": /BGDKHI.
    // Several PAL standards are missing here: /M, /N and /Nc
    pub const PAL            : StdId = V4L2_STD_PAL_BG        | V4L2_STD_PAL_DK        | V4L2_STD_PAL_H         | V4L2_STD_PAL_I;

    // Chroma "agnostic" standards
    pub const B              : StdId = V4L2_STD_PAL_B         | V4L2_STD_PAL_B1        | V4L2_STD_SECAM_B;
    pub const G              : StdId = V4L2_STD_PAL_G         | V4L2_STD_SECAM_G;
    pub const H              : StdId = V4L2_STD_PAL_H         | V4L2_STD_SECAM_H;
    pub const L              : StdId = V4L2_STD_SECAM_L       | V4L2_STD_SECAM_LC;
    pub const GH             : StdId = V4L2_STD_G             | V4L2_STD_H;
    pub const DK             : StdId = V4L2_STD_PAL_DK        | V4L2_STD_SECAM_DK;
    pub const BG             : StdId = V4L2_STD_B             | V4L2_STD_G;
    pub const MN             : StdId = V4L2_STD_PAL_M         | V4L2_STD_PAL_N         | V4L2_STD_PAL_Nc        | V4L2_STD_NTSC;

// Standards where MTS/BTSC stereo could be found
    pub const MTS            : StdId = V4L2_STD_NTSC_M        | V4L2_STD_PAL_M         | V4L2_STD_PAL_N         | V4L2_STD_PAL_Nc;

// Standards for Countries with 60Hz Line frequency
    pub const @"525_60"         : StdId = V4L2_STD_PAL_M         | V4L2_STD_PAL_60        | V4L2_STD_NTSC          | V4L2_STD_NTSC_443;
// Standards for Countries with 50Hz Line frequency
    pub const @"625_50"         : StdId = V4L2_STD_PAL           | V4L2_STD_PAL_N         | V4L2_STD_PAL_Nc        | V4L2_STD_SECAM;

    pub const ATSC           : StdId = V4L2_STD_ATSC_8_VSB    | V4L2_STD_ATSC_16_VSB;
// Macros with none and all analog standards
    pub const UNKNOWN        : StdId = 0;
    pub const ALL            : StdId = V4L2_STD_525_60        | V4L2_STD_625_50;
};

/// v4l2_standard
pub const Standard = extern struct {
        index: u32,
        id: StdId,
        name: [24]u8,
        frameperiod: Fract, // Frames, not fields
        framelines: u32,
        reserved: [4]u32,
};

// ------------------------------------- //
//     D V     B T     T I M I N G S     //
// ------------------------------------- //

///  struct v4l2_bt_timings - BT.656/BT.1120 timing data
/// @width:      total width of the active video in pixels
/// @height:     total height of the active video in lines
/// @interlaced: Interlaced or progressive
/// @polarities: Positive or negative polarities
/// @pixelclock: Pixel clock in HZ. Ex. 74.25MHz->74250000
/// @hfrontporch:Horizontal front porch in pixels
/// @hsync:      Horizontal Sync length in pixels
/// @hbackporch: Horizontal back porch in pixels
/// @vfrontporch:Vertical front porch in lines
/// @vsync:      Vertical Sync length in lines
/// @vbackporch: Vertical back porch in lines
/// @il_vfrontporch:Vertical front porch for the even field
///              (aka field 2) of interlaced field formats
/// @il_vsync:   Vertical Sync length for the even field
///              (aka field 2) of interlaced field formats
/// @il_vbackporch:Vertical back porch for the even field
///              (aka field 2) of interlaced field formats
/// @standards:  Standards the timing belongs to
/// @flags:      Flags
/// @picture_aspect: The picture aspect ratio (hor/vert).
/// @cea861_vic: VIC code as per the CEA-861 standard.
/// @hdmi_vic:   VIC code as per the HDMI standard.
/// @reserved:   Reserved fields, must be zeroed.
///
/// A note regarding vertical interlaced timings: height refers to the total
/// height of the active video frame (= two fields). The blanking timings refer
/// to the blanking of each field. So the height of the total frame is
/// calculated as follows:
///
/// tot_height = height + vfrontporch + vsync + vbackporch +
///                       il_vfrontporch + il_vsync + il_vbackporch
///
/// The active height of each field is height / 2.
pub const BTTimings = extern struct {
        width: u32,
        height: u32,
        interlaced: u32,
        polarities: u32,
        pixelclock: u64,
        hfrontporch: u32,
        hsync: u32,
        hbackporch: u32
        vfrontporch: u32,
        vsync: u32,
        vbackporch: u32,
        il_vfrontporch: u32,
        il_vsync: u32,
        il_vbackporch: u32,
        standards: u32,
        flags: u32,
        picture_aspect: Fract,
        cea861_vic: u8,
        hdmi_vic: u8,
        reserved: [46]u8,

    // A few useful defines to calculate the total blanking and frame sizes
    pub inline fn blankingWidth(bt: BTTimings) u32 {
        return bt.hfrontporch + bt.hsync + bt.hbackporch;
    }
    pub inline fn frameWidth(bt: BTTimings) u32 {
        return bt.width + bt.blankingWidth();
    }
    pub inline fn blankingHeight(bt: BTTimings) u32 {
        return bt.il_vbackporch + bt.vsync + bt.vbackporch;
    }
    pub inline fn frameHeight(bt: BTTimings) u32 {
        return bt.height + bt.blankingHeight();
    }
};

// Interlaced or progressive format
pub const DV_PROGRESSIVE     : u32 = 0;
pub const DV_INTERLACED      : u32 = 1;

// Polarities. If bit is not set, it is assumed to be negative polarity
pub const DV_VSYNC_POS_POL   : u32 = 0x00000001;
pub const DV_HSYNC_POS_POL   : u32 = 0x00000002;

// Timings standards
/// CEA-861 Digital TV Profile
pub const DV_BT_STD_CEA861   : u32 = (1 << 0);
/// VESA Discrete Monitor Timings
pub const DV_BT_STD_DMT      : u32 = (1 << 1);
/// VESA Coordinated Video Timings
pub const DV_BT_STD_CVT      : u32 = (1 << 2);
/// VESA Generalized Timings Formula
pub const DV_BT_STD_GTF      : u32 = (1 << 3);
/// SDI Timings
pub const DV_BT_STD_SDI      : u32 = (1 << 4);

// Flags

/// CVT/GTF specific: timing uses reduced blanking (CVT) or the 'Secondary
/// GTF' curve (GTF). In both cases the horizontal and/or vertical blanking
/// intervals are reduced, allowing a higher resolution over the same
/// bandwidth. This is a read-only flag.
pub const DV_FL_REDUCED_BLANKING             : u32 = (1 << 0);
/// CEA-861 specific: set for CEA-861 formats with a framerate of a multiple
/// of six. These formats can be optionally played at 1 / 1.001 speed.
/// This is a read-only flag.
pub const DV_FL_CAN_REDUCE_FPS               : u32 = (1 << 1);
/// CEA-861 specific: only valid for video transmitters, the flag is cleared
/// by receivers.
/// If the framerate of the format is a multiple of six, then the pixelclock
/// used to set up the transmitter is divided by 1.001 to make it compatible
/// with 60 Hz based standards such as NTSC and PAL-M that use a framerate of
/// 29.97 Hz. Otherwise this flag is cleared. If the transmitter can't generate
/// such frequencies, then the flag will also be cleared.
pub const DV_FL_REDUCED_FPS                  : u32 = (1 << 2);
/// Specific to interlaced formats: if set, then field 1 is really one half-line
/// longer and field 2 is really one half-line shorter, so each field has
/// exactly the same number of half-lines. Whether half-lines can be detected
/// or used depends on the hardware.
pub const DV_FL_HALF_LINE                    : u32 = (1 << 3);
///If set, then this is a Consumer Electronics (CE) video format. Such formats
///differ from other formats (commonly called IT formats) in that if RGB
///encoding is used then by default the RGB values use limited range (i.e.
///use the range 16-235) as opposed to 0-255. All formats defined in CEA-861
///except for the 640x480 format are CE formats.
pub const DV_FL_IS_CE_VIDEO                  : u32 = (1 << 4);
/// Some formats like SMPTE-125M have an interlaced signal with a odd
/// total height. For these formats, if this flag is set, the first
/// field has the extra line. If not, it is the second field.
pub const DV_FL_FIRST_FIELD_EXTRA_LINE       : u32 = (1 << 5);
/// If set, then the picture_aspect field is valid. Otherwise assume that the
/// pixels are square, so the picture aspect ratio is the same as the width to
/// height ratio.
pub const DV_FL_HAS_PICTURE_ASPECT           : u32 = (1 << 6);
/// If set, then the cea861_vic field is valid and contains the Video
/// Identification Code as per the CEA-861 standard.
pub const DV_FL_HAS_CEA861_VIC               : u32 = (1 << 7);
/// If set, then the hdmi_vic field is valid and contains the Video
/// Identification Code as per the HDMI standard (HDMI Vendor Specific
/// InfoFrame).
pub const DV_FL_HAS_HDMI_VIC                 : u32 = (1 << 8);
/// CEA-861 specific: only valid for video receivers.
/// If set, then HW can detect the difference between regular FPS and
/// 1000/1001 FPS. Note: This flag is only valid for HDMI VIC codes with
/// the V4L2_DV_FL_CAN_REDUCE_FPS flag set.
pub const DV_FL_CAN_DETECT_REDUCED_FPS       : u32 = (1 << 9);

///  struct v4l2_dv_timings - DV timings
/// @type:       the type of the timings
/// @bt: BT656/1120 timings
pub const DVTimings = extern struct {
    type: u32,
    _u: extern union {
        bt: BTTimings,
        reserved: [32]u32,
    },
};

// Values for the type field
pub const DV_BT_656_1120     : u32 = 0       // BT.656/1120 timing type

///  struct v4l2_enum_dv_timings - DV timings enumeration
/// @index:      enumeration index
/// @pad:        the pad number for which to enumerate timings (used with
///              v4l-subdev nodes only)
/// @reserved:   must be zeroed
/// @timings:    the timings for the given index
pub const EnumDVTimings = extern struct {
    index: u32,
    pad: u32,
    reserved: [2]u32,
    timings: DVTimings,
};

///  struct v4l2_bt_timings_cap - BT.656/BT.1120 timing capabilities
/// @min_width:          width in pixels
/// @max_width:          width in pixels
/// @min_height:         height in lines
/// @max_height:         height in lines
/// @min_pixelclock:     Pixel clock in HZ. Ex. 74.25MHz->74250000
/// @max_pixelclock:     Pixel clock in HZ. Ex. 74.25MHz->74250000
/// @standards:          Supported standards
/// @capabilities:       Supported capabilities
/// @reserved:           Must be zeroed
pub const BTTimingsCap = extern struct {
        min_width: u32,
        max_width: u32,
        min_height: u32,
        max_height: u32,
        min_pixelclock: u64,
        max_pixelclock: u64,
        standards: u32,
        capabilities: u32,
        reserved: [16]u32,
};

// Supports interlaced formats
pub const DV_BT_CAP_INTERLACED       : u32 = (1 << 0);
// Supports progressive formats
pub const DV_BT_CAP_PROGRESSIVE      : u32 = (1 << 1);
// Supports CVT/GTF reduced blanking
pub const DV_BT_CAP_REDUCED_BLANKING : u32 = (1 << 2);
// Supports custom formats
pub const DV_BT_CAP_CUSTOM           : u32 = (1 << 3);

///  struct v4l2_dv_timings_cap - DV timings capabilities
/// @type:       the type of the timings (same as in struct v4l2_dv_timings)
/// @pad:        the pad number for which to query capabilities (used with
///              v4l-subdev nodes only)
/// @bt:         the BT656/1120 timings capabilities
pub const DVTimingsCap = extern struct {
        type: u32,
        pad: u32,
        reserved: [2]u32,
        _u = extern union {
                bt: BTTimingsCap,
                raw_data: [32]u32,
        },
};

// ------------------------------- //
//     V I D E O   I N P U T S     //
// ------------------------------- //
pub const Input = extern struct {
    index: u32,             //  Which input
    name: [32]u8,          //  Label
    type: u32,              //  Type of input
    audioset: u32,          //  Associated audios (bitfield)
    tuner: TunerType,
    std: StdId,
    status: u32,
    capabilities: u32,
    reserved: [3]u32,

    ///  Values for the 'type' field
    pub const Type = struct {
        pub const INPUT_TYPE_TUNER           : u32 = 1;
        pub const INPUT_TYPE_CAMERA          : u32 = 2;
        pub const INPUT_TYPE_TOUCH           : u32 = 3;
    };

    /// Flags for the 'status' field
    pub const Status = struct {
        // field 'status' - general
        /// Attached device is off
        pub const IN_ST_NO_POWER    : u32 = 0x00000001;
        pub const IN_ST_NO_SIGNAL   : u32 = 0x00000002;
        pub const IN_ST_NO_COLOR    : u32 = 0x00000004;

        // field 'status' - sensor orientation
        // If sensor is mounted upside down set both bits
        /// Frames are flipped horizontally
        pub const IN_ST_HFLIP       : u32 = 0x00000010;
        /// Frames are flipped vertically
        pub const IN_ST_VFLIP       : u32 = 0x00000020;

        // field 'status' - analog
        /// No horizontal sync lock
        pub const IN_ST_NO_H_LOCK   : u32 = 0x00000100;
        /// Color killer is active
        pub const IN_ST_COLOR_KILL  : u32 = 0x00000200;
        /// No vertical sync lock
        pub const IN_ST_NO_V_LOCK   : u32 = 0x00000400;
        /// No standard format lock
        pub const IN_ST_NO_STD_LOCK : u32 = 0x00000800;

        // field 'status' - digital
        /// No synchronization lock
        pub const IN_ST_NO_SYNC     : u32 = 0x00010000;
        /// No equalizer lock
        pub const IN_ST_NO_EQU      : u32 = 0x00020000;
        /// Carrier recovery failed
        pub const IN_ST_NO_CARRIER  : u32 = 0x00040000;

        // field 'status' - VCR and set-top box
        /// Macrovision detected
        pub const IN_ST_MACROVISION : u32 = 0x01000000  ;
        /// Conditional access denied
        pub const IN_ST_NO_ACCESS   : u32 = 0x02000000  ;
        /// VTR time constant
        pub const IN_ST_VTR         : u32 = 0x04000000  ;

    };

    pub const Capabilities = struct {
        // capabilities flags
        /// Supports S_DV_TIMINGS
        pub const IN_CAP_DV_TIMINGS          : u32 = 0x00000002 ;
        /// For compatibility
        pub const IN_CAP_CUSTOM_TIMINGS      : u32 = IN_CAP_DV_TIMINGS;
        /// Supports S_STD
        pub const IN_CAP_STD                 : u32 = 0x00000004 ;
        /// Supports setting native size
        pub const IN_CAP_NATIVE_SIZE         : u32 = 0x00000008 ;

    };

};


// --------------------------------- //
//     V I D E O   O U T P U T S     //
// --------------------------------- //

pub const Output = extern struct {
    index: u32,             //  Which output
    name: [32]u8,          //  Label
    type: u32,              //  Type of output
    audioset:u32,          //  Associated audios (bitfield)
    modulator: u32,         //  Associated modulator
    std: StdId,
    capabilities: u32,
    reserved: [3]u32,

    ///  Values for the 'type' field
    pub const Type = struct {
        pub const OUTPUT_TYPE_MODULATOR              : u32 = 1;
        pub const OUTPUT_TYPE_ANALOG                 : u32 = 2;
        pub const OUTPUT_TYPE_ANALOGVGAOVERLAY       : u32 = 3;
    };

    /// capabilities flags
    pub const Capabilities = struct {
        /// Supports S_DV_TIMINGS
        pub const OUT_CAP_DV_TIMINGS         : u32 = 0x00000002;
        /// For compatibility
        pub const OUT_CAP_CUSTOM_TIMINGS     : u32 = OUT_CAP_DV_TIMINGS;
        /// Supports S_STD
        pub const OUT_CAP_STD                : u32 = 0x00000004;
        /// Supports setting native size
        pub const OUT_CAP_NATIVE_SIZE        : u32 = 0x00000008;
    };
};


// ----------------------- //
//     C O N T R O L S     //
// ----------------------- //

pub const Control = extern struct {
    id: u32,
    value: i32,
};

pub const ExtControl = extern struct {
        id: u32,
        size: u32,
        reserved2: [1]u32,
        _u: extern union {
            value: i32,
            value64: i64,
            string: [*]u8,
            p_u8: [*]u8,
            p_u16: [*]u16,
            p_u32: [*]u32,
            ptr: usize,
        },
};

pub const ExtControls = extern struct {
        union {
#ifndef __KERNEL__
                __u32 ctrl_class;
#endif
                __u32 which;
        };
        __u32 count;
        __u32 error_idx;
        __s32 request_fd;
        __u32 reserved[1];
        struct v4l2_ext_control *controls;
};

#define V4L2_CTRL_ID_MASK         (0x0fffffff)
#ifndef __KERNEL__
#define V4L2_CTRL_ID2CLASS(id)    ((id) & 0x0fff0000UL)
#endif
#define V4L2_CTRL_ID2WHICH(id)    ((id) & 0x0fff0000UL)
#define V4L2_CTRL_DRIVER_PRIV(id) (((id) & 0xffff) >= 0x1000)
#define V4L2_CTRL_MAX_DIMS        (4)
#define V4L2_CTRL_WHICH_CUR_VAL   0
#define V4L2_CTRL_WHICH_DEF_VAL   0x0f000000
#define V4L2_CTRL_WHICH_REQUEST_VAL 0x0f010000

enum v4l2_ctrl_type {
        V4L2_CTRL_TYPE_INTEGER       = 1,
        V4L2_CTRL_TYPE_BOOLEAN       = 2,
        V4L2_CTRL_TYPE_MENU          = 3,
        V4L2_CTRL_TYPE_BUTTON        = 4,
        V4L2_CTRL_TYPE_INTEGER64     = 5,
        V4L2_CTRL_TYPE_CTRL_CLASS    = 6,
        V4L2_CTRL_TYPE_STRING        = 7,
        V4L2_CTRL_TYPE_BITMASK       = 8,
        V4L2_CTRL_TYPE_INTEGER_MENU  = 9,

        /* Compound types are >= 0x0100 */
        V4L2_CTRL_COMPOUND_TYPES     = 0x0100,
        V4L2_CTRL_TYPE_U8            = 0x0100,
        V4L2_CTRL_TYPE_U16           = 0x0101,
        V4L2_CTRL_TYPE_U32           = 0x0102,
};

/*  Used in the VIDIOC_QUERYCTRL ioctl for querying controls */
struct v4l2_queryctrl {
        __u32                id;
        __u32                type;      /* enum v4l2_ctrl_type */
        __u8                 name[32];  /* Whatever */
        __s32                minimum;   /* Note signedness */
        __s32                maximum;
        __s32                step;
        __s32                default_value;
        __u32                flags;
        __u32                reserved[2];
};

/*  Used in the VIDIOC_QUERY_EXT_CTRL ioctl for querying extended controls */
struct v4l2_query_ext_ctrl {
        __u32                id;
        __u32                type;
        char                 name[32];
        __s64                minimum;
        __s64                maximum;
        __u64                step;
        __s64                default_value;
        __u32                flags;
        __u32                elem_size;
        __u32                elems;
        __u32                nr_of_dims;
        __u32                dims[V4L2_CTRL_MAX_DIMS];
        __u32                reserved[32];
};

/*  Used in the VIDIOC_QUERYMENU ioctl for querying menu items */
struct v4l2_querymenu {
        __u32           id;
        __u32           index;
        union {
                __u8    name[32];       /* Whatever */
                __s64   value;
        };
        __u32           reserved;
} __attribute__ ((packed));

/*  Control flags  */
#define V4L2_CTRL_FLAG_DISABLED         0x0001
#define V4L2_CTRL_FLAG_GRABBED          0x0002
#define V4L2_CTRL_FLAG_READ_ONLY        0x0004
#define V4L2_CTRL_FLAG_UPDATE           0x0008
#define V4L2_CTRL_FLAG_INACTIVE         0x0010
#define V4L2_CTRL_FLAG_SLIDER           0x0020
#define V4L2_CTRL_FLAG_WRITE_ONLY       0x0040
#define V4L2_CTRL_FLAG_VOLATILE         0x0080
#define V4L2_CTRL_FLAG_HAS_PAYLOAD      0x0100
#define V4L2_CTRL_FLAG_EXECUTE_ON_WRITE 0x0200
#define V4L2_CTRL_FLAG_MODIFY_LAYOUT    0x0400

/*  Query flags, to be ORed with the control ID */
#define V4L2_CTRL_FLAG_NEXT_CTRL        0x80000000
#define V4L2_CTRL_FLAG_NEXT_COMPOUND    0x40000000

/*  User-class control IDs defined by V4L2 */
#define V4L2_CID_MAX_CTRLS              1024
/*  IDs reserved for driver specific controls */
#define V4L2_CID_PRIVATE_BASE           0x08000000

/*
 *      T U N I N G
 */
struct v4l2_tuner {
        __u32                   index;
        __u8                    name[32];
        __u32                   type;   /* enum v4l2_tuner_type */
        __u32                   capability;
        __u32                   rangelow;
        __u32                   rangehigh;
        __u32                   rxsubchans;
        __u32                   audmode;
        __s32                   signal;
        __s32                   afc;
        __u32                   reserved[4];
};

struct v4l2_modulator {
        __u32                   index;
        __u8                    name[32];
        __u32                   capability;
        __u32                   rangelow;
        __u32                   rangehigh;
        __u32                   txsubchans;
        __u32                   type;   /* enum v4l2_tuner_type */
        __u32                   reserved[3];
};

/*  Flags for the 'capability' field */
#define V4L2_TUNER_CAP_LOW              0x0001
#define V4L2_TUNER_CAP_NORM             0x0002
#define V4L2_TUNER_CAP_HWSEEK_BOUNDED   0x0004
#define V4L2_TUNER_CAP_HWSEEK_WRAP      0x0008
#define V4L2_TUNER_CAP_STEREO           0x0010
#define V4L2_TUNER_CAP_LANG2            0x0020
#define V4L2_TUNER_CAP_SAP              0x0020
#define V4L2_TUNER_CAP_LANG1            0x0040
#define V4L2_TUNER_CAP_RDS              0x0080
#define V4L2_TUNER_CAP_RDS_BLOCK_IO     0x0100
#define V4L2_TUNER_CAP_RDS_CONTROLS     0x0200
#define V4L2_TUNER_CAP_FREQ_BANDS       0x0400
#define V4L2_TUNER_CAP_HWSEEK_PROG_LIM  0x0800
#define V4L2_TUNER_CAP_1HZ              0x1000

/*  Flags for the 'rxsubchans' field */
#define V4L2_TUNER_SUB_MONO             0x0001
#define V4L2_TUNER_SUB_STEREO           0x0002
#define V4L2_TUNER_SUB_LANG2            0x0004
#define V4L2_TUNER_SUB_SAP              0x0004
#define V4L2_TUNER_SUB_LANG1            0x0008
#define V4L2_TUNER_SUB_RDS              0x0010

/*  Values for the 'audmode' field */
#define V4L2_TUNER_MODE_MONO            0x0000
#define V4L2_TUNER_MODE_STEREO          0x0001
#define V4L2_TUNER_MODE_LANG2           0x0002
#define V4L2_TUNER_MODE_SAP             0x0002
#define V4L2_TUNER_MODE_LANG1           0x0003
#define V4L2_TUNER_MODE_LANG1_LANG2     0x0004

struct v4l2_frequency {
        __u32   tuner;
        __u32   type;   /* enum v4l2_tuner_type */
        __u32   frequency;
        __u32   reserved[8];
};

#define V4L2_BAND_MODULATION_VSB        (1 << 1)
#define V4L2_BAND_MODULATION_FM         (1 << 2)
#define V4L2_BAND_MODULATION_AM         (1 << 3)

struct v4l2_frequency_band {
        __u32   tuner;
        __u32   type;   /* enum v4l2_tuner_type */
        __u32   index;
        __u32   capability;
        __u32   rangelow;
        __u32   rangehigh;
        __u32   modulation;
        __u32   reserved[9];
};

struct v4l2_hw_freq_seek {
        __u32   tuner;
        __u32   type;   /* enum v4l2_tuner_type */
        __u32   seek_upward;
        __u32   wrap_around;
        __u32   spacing;
        __u32   rangelow;
        __u32   rangehigh;
        __u32   reserved[5];
};

/*
 *      R D S
 */

struct v4l2_rds_data {
        __u8    lsb;
        __u8    msb;
        __u8    block;
} __attribute__ ((packed));

#define V4L2_RDS_BLOCK_MSK       0x7
#define V4L2_RDS_BLOCK_A         0
#define V4L2_RDS_BLOCK_B         1
#define V4L2_RDS_BLOCK_C         2
#define V4L2_RDS_BLOCK_D         3
#define V4L2_RDS_BLOCK_C_ALT     4
#define V4L2_RDS_BLOCK_INVALID   7

#define V4L2_RDS_BLOCK_CORRECTED 0x40
#define V4L2_RDS_BLOCK_ERROR     0x80

/*
 *      A U D I O
 */
struct v4l2_audio {
        __u32   index;
        __u8    name[32];
        __u32   capability;
        __u32   mode;
        __u32   reserved[2];
};

/*  Flags for the 'capability' field */
#define V4L2_AUDCAP_STEREO              0x00001
#define V4L2_AUDCAP_AVL                 0x00002

/*  Flags for the 'mode' field */
#define V4L2_AUDMODE_AVL                0x00001

struct v4l2_audioout {
        __u32   index;
        __u8    name[32];
        __u32   capability;
        __u32   mode;
        __u32   reserved[2];
};

/*
 *      M P E G   S E R V I C E S
 */
#if 1
#define V4L2_ENC_IDX_FRAME_I    (0)
#define V4L2_ENC_IDX_FRAME_P    (1)
#define V4L2_ENC_IDX_FRAME_B    (2)
#define V4L2_ENC_IDX_FRAME_MASK (0xf)

struct v4l2_enc_idx_entry {
        __u64 offset;
        __u64 pts;
        __u32 length;
        __u32 flags;
        __u32 reserved[2];
};

#define V4L2_ENC_IDX_ENTRIES (64)
struct v4l2_enc_idx {
        __u32 entries;
        __u32 entries_cap;
        __u32 reserved[4];
        struct v4l2_enc_idx_entry entry[V4L2_ENC_IDX_ENTRIES];
};

#define V4L2_ENC_CMD_START      (0)
#define V4L2_ENC_CMD_STOP       (1)
#define V4L2_ENC_CMD_PAUSE      (2)
#define V4L2_ENC_CMD_RESUME     (3)

/* Flags for V4L2_ENC_CMD_STOP */
#define V4L2_ENC_CMD_STOP_AT_GOP_END    (1 << 0)

struct v4l2_encoder_cmd {
        __u32 cmd;
        __u32 flags;
        union {
                struct {
                        __u32 data[8];
                } raw;
        };
};

/* Decoder commands */
#define V4L2_DEC_CMD_START       (0)
#define V4L2_DEC_CMD_STOP        (1)
#define V4L2_DEC_CMD_PAUSE       (2)
#define V4L2_DEC_CMD_RESUME      (3)

/* Flags for V4L2_DEC_CMD_START */
#define V4L2_DEC_CMD_START_MUTE_AUDIO   (1 << 0)

/* Flags for V4L2_DEC_CMD_PAUSE */
#define V4L2_DEC_CMD_PAUSE_TO_BLACK     (1 << 0)

/* Flags for V4L2_DEC_CMD_STOP */
#define V4L2_DEC_CMD_STOP_TO_BLACK      (1 << 0)
#define V4L2_DEC_CMD_STOP_IMMEDIATELY   (1 << 1)

/* Play format requirements (returned by the driver): */

/* The decoder has no special format requirements */
#define V4L2_DEC_START_FMT_NONE         (0)
/* The decoder requires full GOPs */
#define V4L2_DEC_START_FMT_GOP          (1)

/* The structure must be zeroed before use by the application
   This ensures it can be extended safely in the future. */
struct v4l2_decoder_cmd {
        __u32 cmd;
        __u32 flags;
        union {
                struct {
                        __u64 pts;
                } stop;

                struct {
                        /* 0 or 1000 specifies normal speed,
                           1 specifies forward single stepping,
                           -1 specifies backward single stepping,
                           >1: playback at speed/1000 of the normal speed,
                           <-1: reverse playback at (-speed/1000) of the normal speed. */
                        __s32 speed;
                        __u32 format;
                } start;

                struct {
                        __u32 data[16];
                } raw;
        };
};
#endif

/*
 *      D A T A   S E R V I C E S   ( V B I )
 *
 *      Data services API by Michael Schimek
 */

/* Raw VBI */
struct v4l2_vbi_format {
        __u32   sampling_rate;          /* in 1 Hz */
        __u32   offset;
        __u32   samples_per_line;
        __u32   sample_format;          /* V4L2_PIX_FMT_* */
        __s32   start[2];
        __u32   count[2];
        __u32   flags;                  /* V4L2_VBI_* */
        __u32   reserved[2];            /* must be zero */
};

/*  VBI flags  */
#define V4L2_VBI_UNSYNC         (1 << 0)
#define V4L2_VBI_INTERLACED     (1 << 1)

/* ITU-R start lines for each field */
#define V4L2_VBI_ITU_525_F1_START (1)
#define V4L2_VBI_ITU_525_F2_START (264)
#define V4L2_VBI_ITU_625_F1_START (1)
#define V4L2_VBI_ITU_625_F2_START (314)

/* Sliced VBI
 *
 *    This implements is a proposal V4L2 API to allow SLICED VBI
 * required for some hardware encoders. It should change without
 * notice in the definitive implementation.
 */

struct v4l2_sliced_vbi_format {
        __u16   service_set;
        /* service_lines[0][...] specifies lines 0-23 (1-23 used) of the first field
           service_lines[1][...] specifies lines 0-23 (1-23 used) of the second field
                                 (equals frame lines 313-336 for 625 line video
                                  standards, 263-286 for 525 line standards) */
        __u16   service_lines[2][24];
        __u32   io_size;
        __u32   reserved[2];            /* must be zero */
};

/* Teletext World System Teletext
   (WST), defined on ITU-R BT.653-2 */
#define V4L2_SLICED_TELETEXT_B          (0x0001)
/* Video Program System, defined on ETS 300 231*/
#define V4L2_SLICED_VPS                 (0x0400)
/* Closed Caption, defined on EIA-608 */
#define V4L2_SLICED_CAPTION_525         (0x1000)
/* Wide Screen System, defined on ITU-R BT1119.1 */
#define V4L2_SLICED_WSS_625             (0x4000)

#define V4L2_SLICED_VBI_525             (V4L2_SLICED_CAPTION_525)
#define V4L2_SLICED_VBI_625             (V4L2_SLICED_TELETEXT_B | V4L2_SLICED_VPS | V4L2_SLICED_WSS_625)

struct v4l2_sliced_vbi_cap {
        __u16   service_set;
        /* service_lines[0][...] specifies lines 0-23 (1-23 used) of the first field
           service_lines[1][...] specifies lines 0-23 (1-23 used) of the second field
                                 (equals frame lines 313-336 for 625 line video
                                  standards, 263-286 for 525 line standards) */
        __u16   service_lines[2][24];
        __u32   type;           /* enum v4l2_buf_type */
        __u32   reserved[3];    /* must be 0 */
};

struct v4l2_sliced_vbi_data {
        __u32   id;
        __u32   field;          /* 0: first field, 1: second field */
        __u32   line;           /* 1-23 */
        __u32   reserved;       /* must be 0 */
        __u8    data[48];
};

/*
 * Sliced VBI data inserted into MPEG Streams
 */

/*
 * V4L2_MPEG_STREAM_VBI_FMT_IVTV:
 *
 * Structure of payload contained in an MPEG 2 Private Stream 1 PES Packet in an
 * MPEG-2 Program Pack that contains V4L2_MPEG_STREAM_VBI_FMT_IVTV Sliced VBI
 * data
 *
 * Note, the MPEG-2 Program Pack and Private Stream 1 PES packet header
 * definitions are not included here.  See the MPEG-2 specifications for details
 * on these headers.
 */

/* Line type IDs */
#define V4L2_MPEG_VBI_IVTV_TELETEXT_B     (1)
#define V4L2_MPEG_VBI_IVTV_CAPTION_525    (4)
#define V4L2_MPEG_VBI_IVTV_WSS_625        (5)
#define V4L2_MPEG_VBI_IVTV_VPS            (7)

struct v4l2_mpeg_vbi_itv0_line {
        __u8 id;        /* One of V4L2_MPEG_VBI_IVTV_* above */
        __u8 data[42];  /* Sliced VBI data for the line */
} __attribute__ ((packed));

struct v4l2_mpeg_vbi_itv0 {
        __le32 linemask[2]; /* Bitmasks of VBI service lines present */
        struct v4l2_mpeg_vbi_itv0_line line[35];
} __attribute__ ((packed));

struct v4l2_mpeg_vbi_ITV0 {
        struct v4l2_mpeg_vbi_itv0_line line[36];
} __attribute__ ((packed));

#define V4L2_MPEG_VBI_IVTV_MAGIC0       "itv0"
#define V4L2_MPEG_VBI_IVTV_MAGIC1       "ITV0"

struct v4l2_mpeg_vbi_fmt_ivtv {
        __u8 magic[4];
        union {
                struct v4l2_mpeg_vbi_itv0 itv0;
                struct v4l2_mpeg_vbi_ITV0 ITV0;
        };
} __attribute__ ((packed));

/*
 *      A G G R E G A T E   S T R U C T U R E S
 */

/**
 * struct v4l2_plane_pix_format - additional, per-plane format definition
 * @sizeimage:          maximum size in bytes required for data, for which
 *                      this plane will be used
 * @bytesperline:       distance in bytes between the leftmost pixels in two
 *                      adjacent lines
 */
struct v4l2_plane_pix_format {
        __u32           sizeimage;
        __u32           bytesperline;
        __u16           reserved[6];
} __attribute__ ((packed));

/**
 * struct v4l2_pix_format_mplane - multiplanar format definition
 * @width:              image width in pixels
 * @height:             image height in pixels
 * @pixelformat:        little endian four character code (fourcc)
 * @field:              enum v4l2_field; field order (for interlaced video)
 * @colorspace:         enum v4l2_colorspace; supplemental to pixelformat
 * @plane_fmt:          per-plane information
 * @num_planes:         number of planes for this format
 * @flags:              format flags (V4L2_PIX_FMT_FLAG_*)
 * @ycbcr_enc:          enum v4l2_ycbcr_encoding, Y'CbCr encoding
 * @quantization:       enum v4l2_quantization, colorspace quantization
 * @xfer_func:          enum v4l2_xfer_func, colorspace transfer function
 */
struct v4l2_pix_format_mplane {
        __u32                           width;
        __u32                           height;
        __u32                           pixelformat;
        __u32                           field;
        __u32                           colorspace;

        struct v4l2_plane_pix_format    plane_fmt[VIDEO_MAX_PLANES];
        __u8                            num_planes;
        __u8                            flags;
         union {
                __u8                            ycbcr_enc;
                __u8                            hsv_enc;
        };
        __u8                            quantization;
        __u8                            xfer_func;
        __u8                            reserved[7];
} __attribute__ ((packed));

/**
 * struct v4l2_sdr_format - SDR format definition
 * @pixelformat:        little endian four character code (fourcc)
 * @buffersize:         maximum size in bytes required for data
 */
struct v4l2_sdr_format {
        __u32                           pixelformat;
        __u32                           buffersize;
        __u8                            reserved[24];
} __attribute__ ((packed));

/**
 * struct v4l2_meta_format - metadata format definition
 * @dataformat:         little endian four character code (fourcc)
 * @buffersize:         maximum size in bytes required for data
 */
struct v4l2_meta_format {
        __u32                           dataformat;
        __u32                           buffersize;
} __attribute__ ((packed));

/**
 * struct v4l2_format - stream data format
 * @type:       enum v4l2_buf_type; type of the data stream
 * @pix:        definition of an image format
 * @pix_mp:     definition of a multiplanar image format
 * @win:        definition of an overlaid image
 * @vbi:        raw VBI capture or output parameters
 * @sliced:     sliced VBI capture or output parameters
 * @raw_data:   placeholder for future extensions and custom formats
 */
struct v4l2_format {
        __u32    type;
        union {
                struct v4l2_pix_format          pix;     /* V4L2_BUF_TYPE_VIDEO_CAPTURE */
                struct v4l2_pix_format_mplane   pix_mp;  /* V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE */
                struct v4l2_window              win;     /* V4L2_BUF_TYPE_VIDEO_OVERLAY */
                struct v4l2_vbi_format          vbi;     /* V4L2_BUF_TYPE_VBI_CAPTURE */
                struct v4l2_sliced_vbi_format   sliced;  /* V4L2_BUF_TYPE_SLICED_VBI_CAPTURE */
                struct v4l2_sdr_format          sdr;     /* V4L2_BUF_TYPE_SDR_CAPTURE */
                struct v4l2_meta_format         meta;    /* V4L2_BUF_TYPE_META_CAPTURE */
                __u8    raw_data[200];                   /* user-defined */
        } fmt;
};

/*      Stream type-dependent parameters
 */
struct v4l2_streamparm {
        __u32    type;                  /* enum v4l2_buf_type */
        union {
                struct v4l2_captureparm capture;
                struct v4l2_outputparm  output;
                __u8    raw_data[200];  /* user-defined */
        } parm;
};

/*
 *      E V E N T S
 */

#define V4L2_EVENT_ALL                          0
#define V4L2_EVENT_VSYNC                        1
#define V4L2_EVENT_EOS                          2
#define V4L2_EVENT_CTRL                         3
#define V4L2_EVENT_FRAME_SYNC                   4
#define V4L2_EVENT_SOURCE_CHANGE                5
#define V4L2_EVENT_MOTION_DET                   6
#define V4L2_EVENT_PRIVATE_START                0x08000000

/* Payload for V4L2_EVENT_VSYNC */
struct v4l2_event_vsync {
        /* Can be V4L2_FIELD_ANY, _NONE, _TOP or _BOTTOM */
        __u8 field;
} __attribute__ ((packed));

/* Payload for V4L2_EVENT_CTRL */
#define V4L2_EVENT_CTRL_CH_VALUE                (1 << 0)
#define V4L2_EVENT_CTRL_CH_FLAGS                (1 << 1)
#define V4L2_EVENT_CTRL_CH_RANGE                (1 << 2)

struct v4l2_event_ctrl {
        __u32 changes;
        __u32 type;
        union {
                __s32 value;
                __s64 value64;
        };
        __u32 flags;
        __s32 minimum;
        __s32 maximum;
        __s32 step;
        __s32 default_value;
};

struct v4l2_event_frame_sync {
        __u32 frame_sequence;
};

#define V4L2_EVENT_SRC_CH_RESOLUTION            (1 << 0)

struct v4l2_event_src_change {
        __u32 changes;
};

#define V4L2_EVENT_MD_FL_HAVE_FRAME_SEQ (1 << 0)

/**
 * struct v4l2_event_motion_det - motion detection event
 * @flags:             if V4L2_EVENT_MD_FL_HAVE_FRAME_SEQ is set, then the
 *                     frame_sequence field is valid.
 * @frame_sequence:    the frame sequence number associated with this event.
 * @region_mask:       which regions detected motion.
 */
struct v4l2_event_motion_det {
        __u32 flags;
        __u32 frame_sequence;
        __u32 region_mask;
};

struct v4l2_event {
        __u32                           type;
        union {
                struct v4l2_event_vsync         vsync;
                struct v4l2_event_ctrl          ctrl;
                struct v4l2_event_frame_sync    frame_sync;
                struct v4l2_event_src_change    src_change;
                struct v4l2_event_motion_det    motion_det;
                __u8                            data[64];
        } u;
        __u32                           pending;
        __u32                           sequence;
        struct timespec                 timestamp;
        __u32                           id;
        __u32                           reserved[8];
};

#define V4L2_EVENT_SUB_FL_SEND_INITIAL          (1 << 0)
#define V4L2_EVENT_SUB_FL_ALLOW_FEEDBACK        (1 << 1)

struct v4l2_event_subscription {
        __u32                           type;
        __u32                           id;
        __u32                           flags;
        __u32                           reserved[5];
};

/*
 *      A D V A N C E D   D E B U G G I N G
 *
 *      NOTE: EXPERIMENTAL API, NEVER RELY ON THIS IN APPLICATIONS!
 *      FOR DEBUGGING, TESTING AND INTERNAL USE ONLY!
 */

/* VIDIOC_DBG_G_REGISTER and VIDIOC_DBG_S_REGISTER */

#define V4L2_CHIP_MATCH_BRIDGE      0  /* Match against chip ID on the bridge (0 for the bridge) */
#define V4L2_CHIP_MATCH_SUBDEV      4  /* Match against subdev index */

/* The following four defines are no longer in use */
#define V4L2_CHIP_MATCH_HOST V4L2_CHIP_MATCH_BRIDGE
#define V4L2_CHIP_MATCH_I2C_DRIVER  1  /* Match against I2C driver name */
#define V4L2_CHIP_MATCH_I2C_ADDR    2  /* Match against I2C 7-bit address */
#define V4L2_CHIP_MATCH_AC97        3  /* Match against ancillary AC97 chip */

struct v4l2_dbg_match {
        __u32 type; /* Match type */
        union {     /* Match this chip, meaning determined by type */
                __u32 addr;
                char name[32];
        };
} __attribute__ ((packed));

struct v4l2_dbg_register {
        struct v4l2_dbg_match match;
        __u32 size;     /* register size in bytes */
        __u64 reg;
        __u64 val;
} __attribute__ ((packed));

#define V4L2_CHIP_FL_READABLE (1 << 0)
#define V4L2_CHIP_FL_WRITABLE (1 << 1)

/* VIDIOC_DBG_G_CHIP_INFO */
struct v4l2_dbg_chip_info {
        struct v4l2_dbg_match match;
        char name[32];
        __u32 flags;
        __u32 reserved[32];
} __attribute__ ((packed));

/**
 * struct v4l2_create_buffers - VIDIOC_CREATE_BUFS argument
 * @index:      on return, index of the first created buffer
 * @count:      entry: number of requested buffers,
 *              return: number of created buffers
 * @memory:     enum v4l2_memory; buffer memory type
 * @format:     frame format, for which buffers are requested
 * @capabilities: capabilities of this buffer type.
 * @reserved:   future extensions
 */
struct v4l2_create_buffers {
        __u32                   index;
        __u32                   count;
        __u32                   memory;
        struct v4l2_format      format;
        __u32                   capabilities;
        __u32                   reserved[7];
};

/*
 *      I O C T L   C O D E S   F O R   V I D E O   D E V I C E S
 *
 */
#define VIDIOC_QUERYCAP          _IOR('V',  0, struct v4l2_capability)
#define VIDIOC_ENUM_FMT         _IOWR('V',  2, struct v4l2_fmtdesc)
#define VIDIOC_G_FMT            _IOWR('V',  4, struct v4l2_format)
#define VIDIOC_S_FMT            _IOWR('V',  5, struct v4l2_format)
#define VIDIOC_REQBUFS          _IOWR('V',  8, struct v4l2_requestbuffers)
#define VIDIOC_QUERYBUF         _IOWR('V',  9, struct v4l2_buffer)
#define VIDIOC_G_FBUF            _IOR('V', 10, struct v4l2_framebuffer)
#define VIDIOC_S_FBUF            _IOW('V', 11, struct v4l2_framebuffer)
#define VIDIOC_OVERLAY           _IOW('V', 14, int)
#define VIDIOC_QBUF             _IOWR('V', 15, struct v4l2_buffer)
#define VIDIOC_EXPBUF           _IOWR('V', 16, struct v4l2_exportbuffer)
#define VIDIOC_DQBUF            _IOWR('V', 17, struct v4l2_buffer)
#define VIDIOC_STREAMON          _IOW('V', 18, int)
#define VIDIOC_STREAMOFF         _IOW('V', 19, int)
#define VIDIOC_G_PARM           _IOWR('V', 21, struct v4l2_streamparm)
#define VIDIOC_S_PARM           _IOWR('V', 22, struct v4l2_streamparm)
#define VIDIOC_G_STD             _IOR('V', 23, v4l2_std_id)
#define VIDIOC_S_STD             _IOW('V', 24, v4l2_std_id)
#define VIDIOC_ENUMSTD          _IOWR('V', 25, struct v4l2_standard)
#define VIDIOC_ENUMINPUT        _IOWR('V', 26, struct v4l2_input)
#define VIDIOC_G_CTRL           _IOWR('V', 27, struct v4l2_control)
#define VIDIOC_S_CTRL           _IOWR('V', 28, struct v4l2_control)
#define VIDIOC_G_TUNER          _IOWR('V', 29, struct v4l2_tuner)
#define VIDIOC_S_TUNER           _IOW('V', 30, struct v4l2_tuner)
#define VIDIOC_G_AUDIO           _IOR('V', 33, struct v4l2_audio)
#define VIDIOC_S_AUDIO           _IOW('V', 34, struct v4l2_audio)
#define VIDIOC_QUERYCTRL        _IOWR('V', 36, struct v4l2_queryctrl)
#define VIDIOC_QUERYMENU        _IOWR('V', 37, struct v4l2_querymenu)
#define VIDIOC_G_INPUT           _IOR('V', 38, int)
#define VIDIOC_S_INPUT          _IOWR('V', 39, int)
#define VIDIOC_G_EDID           _IOWR('V', 40, struct v4l2_edid)
#define VIDIOC_S_EDID           _IOWR('V', 41, struct v4l2_edid)
#define VIDIOC_G_OUTPUT          _IOR('V', 46, int)
#define VIDIOC_S_OUTPUT         _IOWR('V', 47, int)
#define VIDIOC_ENUMOUTPUT       _IOWR('V', 48, struct v4l2_output)
#define VIDIOC_G_AUDOUT          _IOR('V', 49, struct v4l2_audioout)
#define VIDIOC_S_AUDOUT          _IOW('V', 50, struct v4l2_audioout)
#define VIDIOC_G_MODULATOR      _IOWR('V', 54, struct v4l2_modulator)
#define VIDIOC_S_MODULATOR       _IOW('V', 55, struct v4l2_modulator)
#define VIDIOC_G_FREQUENCY      _IOWR('V', 56, struct v4l2_frequency)
#define VIDIOC_S_FREQUENCY       _IOW('V', 57, struct v4l2_frequency)
#define VIDIOC_CROPCAP          _IOWR('V', 58, struct v4l2_cropcap)
#define VIDIOC_G_CROP           _IOWR('V', 59, struct v4l2_crop)
#define VIDIOC_S_CROP            _IOW('V', 60, struct v4l2_crop)
#define VIDIOC_G_JPEGCOMP        _IOR('V', 61, struct v4l2_jpegcompression)
#define VIDIOC_S_JPEGCOMP        _IOW('V', 62, struct v4l2_jpegcompression)
#define VIDIOC_QUERYSTD          _IOR('V', 63, v4l2_std_id)
#define VIDIOC_TRY_FMT          _IOWR('V', 64, struct v4l2_format)
#define VIDIOC_ENUMAUDIO        _IOWR('V', 65, struct v4l2_audio)
#define VIDIOC_ENUMAUDOUT       _IOWR('V', 66, struct v4l2_audioout)
#define VIDIOC_G_PRIORITY        _IOR('V', 67, __u32) /* enum v4l2_priority */
#define VIDIOC_S_PRIORITY        _IOW('V', 68, __u32) /* enum v4l2_priority */
#define VIDIOC_G_SLICED_VBI_CAP _IOWR('V', 69, struct v4l2_sliced_vbi_cap)
#define VIDIOC_LOG_STATUS         _IO('V', 70)
#define VIDIOC_G_EXT_CTRLS      _IOWR('V', 71, struct v4l2_ext_controls)
#define VIDIOC_S_EXT_CTRLS      _IOWR('V', 72, struct v4l2_ext_controls)
#define VIDIOC_TRY_EXT_CTRLS    _IOWR('V', 73, struct v4l2_ext_controls)
#define VIDIOC_ENUM_FRAMESIZES  _IOWR('V', 74, struct v4l2_frmsizeenum)
#define VIDIOC_ENUM_FRAMEINTERVALS _IOWR('V', 75, struct v4l2_frmivalenum)
#define VIDIOC_G_ENC_INDEX       _IOR('V', 76, struct v4l2_enc_idx)
#define VIDIOC_ENCODER_CMD      _IOWR('V', 77, struct v4l2_encoder_cmd)
#define VIDIOC_TRY_ENCODER_CMD  _IOWR('V', 78, struct v4l2_encoder_cmd)

/*
 * Experimental, meant for debugging, testing and internal use.
 * Only implemented if CONFIG_VIDEO_ADV_DEBUG is defined.
 * You must be root to use these ioctls. Never use these in applications!
 */
#define VIDIOC_DBG_S_REGISTER    _IOW('V', 79, struct v4l2_dbg_register)
#define VIDIOC_DBG_G_REGISTER   _IOWR('V', 80, struct v4l2_dbg_register)

#define VIDIOC_S_HW_FREQ_SEEK    _IOW('V', 82, struct v4l2_hw_freq_seek)
#define VIDIOC_S_DV_TIMINGS     _IOWR('V', 87, struct v4l2_dv_timings)
#define VIDIOC_G_DV_TIMINGS     _IOWR('V', 88, struct v4l2_dv_timings)
#define VIDIOC_DQEVENT           _IOR('V', 89, struct v4l2_event)
#define VIDIOC_SUBSCRIBE_EVENT   _IOW('V', 90, struct v4l2_event_subscription)
#define VIDIOC_UNSUBSCRIBE_EVENT _IOW('V', 91, struct v4l2_event_subscription)
#define VIDIOC_CREATE_BUFS      _IOWR('V', 92, struct v4l2_create_buffers)
#define VIDIOC_PREPARE_BUF      _IOWR('V', 93, struct v4l2_buffer)
#define VIDIOC_G_SELECTION      _IOWR('V', 94, struct v4l2_selection)
#define VIDIOC_S_SELECTION      _IOWR('V', 95, struct v4l2_selection)
#define VIDIOC_DECODER_CMD      _IOWR('V', 96, struct v4l2_decoder_cmd)
#define VIDIOC_TRY_DECODER_CMD  _IOWR('V', 97, struct v4l2_decoder_cmd)
#define VIDIOC_ENUM_DV_TIMINGS  _IOWR('V', 98, struct v4l2_enum_dv_timings)
#define VIDIOC_QUERY_DV_TIMINGS  _IOR('V', 99, struct v4l2_dv_timings)
#define VIDIOC_DV_TIMINGS_CAP   _IOWR('V', 100, struct v4l2_dv_timings_cap)
#define VIDIOC_ENUM_FREQ_BANDS  _IOWR('V', 101, struct v4l2_frequency_band)

/*
 * Experimental, meant for debugging, testing and internal use.
 * Never use this in applications!
 */
#define VIDIOC_DBG_G_CHIP_INFO  _IOWR('V', 102, struct v4l2_dbg_chip_info)

#define VIDIOC_QUERY_EXT_CTRL   _IOWR('V', 103, struct v4l2_query_ext_ctrl)

/* Reminder: when adding new ioctls please add support for them to
   drivers/media/v4l2-core/v4l2-compat-ioctl32.c as well! */

#define BASE_VIDIOC_PRIVATE     192             /* 192-255 are private */

#endif /* _UAPI__LINUX_VIDEODEV2_H */
