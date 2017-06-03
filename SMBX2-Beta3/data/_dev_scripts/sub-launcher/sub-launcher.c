
#define _CRT_MEMORY_DEFINED
void* memset(void *b, int c, int len);

#include <windows.h>

/************************************************************
************* RELATIVE PATH TO LAUNCHER ITSELF **************
*************************************************************/
const wchar_t *runApp = L"\\data\\SMBXLauncher.exe";
/************************************************************/


int WINAPI WinMain(
    HINSTANCE hInstance,
    HINSTANCE hPrevInstance,
    LPSTR     lpCmdLine,
    int       nCmdShow
);

void    removeFilePathW(wchar_t* path, int *length);
void    WStrAppend(wchar_t* target, int sizet, const wchar_t* str, int sizes);
void    WStrCpy(wchar_t* target, const wchar_t* source, int size);
int     WStrLen(const wchar_t* target);
void*   mySet(void *b, int c, int len);

int WINAPI WinMain(
  HINSTANCE hInstance,
  HINSTANCE hPrevInstance,
  LPSTR     lpCmdLine,
  int       nCmdShow
)
{
    HMODULE hModule = GetModuleHandleW(NULL);
    wchar_t fullPath[MAX_PATH];
    wchar_t fullAppPath[MAX_PATH];
    wchar_t workDir[MAX_PATH];
    STARTUPINFO si;
    PROCESS_INFORMATION pi;
    int workDirLen = 0;
    int fullPathLen = GetModuleFileNameW(hModule, fullPath, MAX_PATH);

    memset( &si, 0, sizeof(si) );
    si.cb = sizeof(si);
    memset( &pi, 0, sizeof(pi) );

    //Remove self EXE name
    removeFilePathW(fullPath, &fullPathLen);

    //Making full path to target application
    WStrCpy(fullAppPath, fullPath, fullPathLen);
    WStrAppend(fullAppPath, fullPathLen, runApp, WStrLen(runApp));

    //Making full path to working directory
    workDirLen = WStrLen(fullAppPath);
    WStrCpy(workDir, fullAppPath, workDirLen);
    removeFilePathW(workDir, &workDirLen);

    //Starting process!
    CreateProcessW(NULL, fullAppPath, 0, 0, FALSE, 0, NULL, workDir, &si, &pi);

    return 0;
}

/*!
 * \brief Removes last entry of path to file (to get directory path)
 * \param path full path to file
 * \param length lenght of file path string (in characters)
 */
void removeFilePathW(wchar_t* path, int *length)
{
    int len = (*length);
    int i = len-1;
    for(; i > 3; i--)
    {
        if( (path[i] == L'\\') || (path[i] == L'/') )
        {
            path[i] = 0;
            *length = (i+1);
            break;
        }
    }
}

/*!
 * \brief Append one string to other
 * \param target target string to append
 * \param sizet size of target string in characters
 * \param str string to add
 * \param sizes size of string to add in characters
 */
void WStrAppend(wchar_t* target, int sizet, const wchar_t* str, int sizes)
{
    int i=(sizet-1);
    int j=0;
    for(; i < (sizet+sizes) && (i<MAX_PATH-1); i++, j++)
    {
        target[i] = str[j];
    }
    target[i] = L'\0';
}

/*!
 * \brief Copy one string to another
 * \param target target string
 * \param source source string
 * \param size string length in characters
 */
void WStrCpy(wchar_t* target, const wchar_t* source, int size)
{
    int i=0;
    for(; (i < size-1) && (i<MAX_PATH-1) ; i++)
    {
        target[i] = source[i];
    }
    target[i] = L'\0';
}

/*!
 * \brief Returns length of null-ternimated string
 * \param target string to check length
 * \return length of string
 */
int WStrLen(const wchar_t* target)
{
    int i=0;
    while( (target[i] != L'\0') && (i<MAX_PATH) )
        i++;
    return i;
}

/*!
 * \brief Custom implementation of memset() from standard C library
 * \param b target memory address
 * \param c data to set into memory block
 * \param len size of target memory block in bytes
 * \return address to target memory address
 */
void* memset(void *b, int c, int len)
{
    int           i;
    unsigned char *p = b;
    i = 0;
    while(len > 0)
    {
        *p = c;
        p++;
        len--;
    }
    return (b);
}
