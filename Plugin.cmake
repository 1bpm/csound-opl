set(PLUGIN_NAME adlmidi)
set(INCLUDES "include" ${CSOUND_INCLUDE_DIRS})
set(LIBS "")

# Dependencies
find_package(ADLMIDI)
check_deps(ADLMIDI_FOUND)
list(APPEND LIBS ${ADLMIDI_LIBRARY})
list(APPEND INCLUDES ${ADLMIDI_INCLUDE_DIR})

# Source files
set(CPPFILES src/opcodes.cpp)
make_plugin(${PLUGIN_NAME} "${CPPFILES}" ${LIBS})
target_include_directories(${PLUGIN_NAME} PRIVATE ${INCLUDES})
