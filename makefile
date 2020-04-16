# makefile for masm32v11

SRC_DIR = .\src
BUILD_DIR = .\build

EXECUTABLE = $(BUILD_DIR)\ScoureProgram.exe
OBJS = $(BUILD_DIR)\main.obj
RES  = $(SRC_DIR)\main.res

LINK_FLAG = /subsystem:windows /out:$(EXECUTABLE)
ML_FLAG = /c /coff 

$(EXECUTABLE) : $(OBJS) $(RES) $(BUILD_DIR)
	link $(LINK_FLAG) $(OBJS) $(RES) 

$(BUILD_DIR)\main.obj : $(SRC_DIR)\main.asm $(BUILD_DIR)
	ml $(ML_FLAG) /Fo $(BUILD_DIR)\main.obj $(SRC_DIR)\main.asm


$(BUILD_DIR) :
	mkdir $(BUILD_DIR)

clean :
	del $(BUILD_DIR)\*.exe
	del $(BUILD_DIR)\*.obj

rebuild : clean $(EXECUTABLE)
