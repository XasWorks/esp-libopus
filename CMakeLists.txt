
include(${COMPONENT_DIR}/celt_sources.mk)
include(${COMPONENT_DIR}/opus_sources.mk)
include(${COMPONENT_DIR}/silk_sources.mk)

list(APPEND srcs ${CELT_SOURCES} 
	${OPUS_SOURCES} ${SILK_SOURCES} 
	${SILK_SOURCES_FIXED})

set(PRIV_INCLUDES "celt/" "silk/" "silk/fixed" "src/")

idf_component_register(SRCS ${srcs}
                       INCLUDE_DIRS "include"
                       PRIV_INCLUDE_DIRS ${PRIV_INCLUDES})

target_compile_options(${COMPONENT_LIB} PRIVATE -DHAVE_ALLOCA_H -DHAVE_LRINT 
	-DHAVE_LRINTF -DFIXED_POINT -DDISABLE_FLOAT_API -DHAVE_MEMORY_H -DUSE_ALLOCA
	-DOPUS_BUILD -O2)