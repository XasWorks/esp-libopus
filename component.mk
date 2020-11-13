
COMPONENT_PRIV_INCLUDEDIRS := celt/ silk/ silk/fixed/ src/
COMPONENT_SRCDIRS := celt/ celt/arm/ silk/ silk/arm/ silk/fixed/ silk/fixed/arm/ src/

CFLAGS += -D HAVE_ALLOCA_H -D HAVE_LRINT -D HAVE_LRINTF -D FIXED_POINT -D DISABLE_FLOAT_API -D HAVE_MEMORY_H -D USE_ALLOCA -D OPUS_BUILD -O3
