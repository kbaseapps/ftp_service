/*
A KBase module: ftp_service
This module serve as a service that lists files and file info in users private ftp space
*/

module ftp_service {

    typedef structure {
        string token;
        string type;
        string search_word;
        string username;
    } listFilesInputParams;

    typedef structure {
        string file_link;
        string file_name;
        float file_size;
        string file_type;
        string isFolder;
        string date;
    }fileInfo;

    typedef structure {
        list <fileInfo> files;
        string username;
    } searchListFilesOutputPparams;

    funcdef search_list_files(listFilesInputParams params) returns (searchListFilesOutputPparams output) authentication required;


        typedef list <string> filepathList;

    funcdef list_files (listFilesInputParams params) returns (filepathList) authentication required;
};
