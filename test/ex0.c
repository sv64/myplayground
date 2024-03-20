#include <stdio.h>
#include <yaml.h>

int main(void) {
    char yamlfile[2048] = {0};
    printf("YAML file?");
    scanf("%s", yamlfile);
    FILE *fh = fopen(yamlfile, "r");
    yaml_parser_t parser;
    yaml_token_t  token;   
    
    if (!yaml_parser_initialize(&parser)) { 
        fputs("Failed to initialize parser!\n", stderr);
    }
    if (fh == NULL) {
        fputs("Failed to open file!\n", stderr);
    }

    yaml_parser_set_input_file(&parser, fh);

    
    do {
        yaml_parser_scan(&parser, &token);
        switch(token.type) {
        case YAML_KEY_TOKEN:
            printf("Key: ");
            break;
        case YAML_VALUE_TOKEN:
            printf("Value: ");
            break;
        case YAML_SCALAR_TOKEN:
            printf("%s\n", token.data.scalar.value);
            break;
        default:
            
            break;
        }
        if(token.type != YAML_STREAM_END_TOKEN)
            yaml_token_delete(&token);
    } while(token.type != YAML_STREAM_END_TOKEN);
    yaml_token_delete(&token);
    
    
    yaml_parser_delete(&parser);
    fclose(fh);

    return 0;
}
