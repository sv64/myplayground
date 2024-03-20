#include <stdio.h>
#include <stdlib.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int main() {
    int val = 5; 
    printf("Original value: %d\n", val);

    lua_State *L = luaL_newstate(); 
    luaL_openlibs(L); 

    
    if (luaL_dofile(L, "ex1.lua") != LUA_OK) {
        fprintf(stderr, "Could not load script: %s\n", lua_tostring(L, -1));
        exit(1);
    }

    lua_getglobal(L, "value"); 
    if (lua_isnumber(L, -1)) {
        val = (int)lua_tonumber(L, -1); 
    } else {
        fprintf(stderr, "Expected a number\n");
        exit(1);
    }

    printf("Modified value: %d\n", val);

    lua_close(L); 
    return 0;
}
