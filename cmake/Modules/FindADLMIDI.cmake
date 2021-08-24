# This module defines
# ADLMIDI_LIBRARY, the name of the library to link against
# ADLMIDI_FOUND, if false, do not try to link to ADLMIDI
# ADLMIDI_INCLUDE_DIR, where to find adlmidi.h
#

SET(ADLMIDI_SEARCH_PATHS
	~/Library/Frameworks
	/Library/Frameworks
	/usr/local
	/usr
	/sw # Fink
	/opt/local # DarwinPorts
	/opt/csw # Blastwave
	/opt
)

FIND_PATH(ADLMIDI_INCLUDE_DIR adlmidi.h)

if(CMAKE_SIZEOF_VOID_P EQUAL 8) 
	set(PATH_SUFFIXES lib64 lib/x64 lib)
else() 
	set(PATH_SUFFIXES lib/x86 lib)
endif() 

FIND_LIBRARY(ADLMIDI_LIBRARY
	NAMES ADLMIDI
	PATH_SUFFIXES ${PATH_SUFFIXES}
	PATHS ${ADLMIDI_SEARCH_PATHS}
)

INCLUDE(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(ADLMIDI REQUIRED_VARS ADLMIDI_LIBRARY ADLMIDI_INCLUDE_DIR)
