
package us.kbase.ftpservice;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * <p>Original spec-file type: searchListFilesOutputPparams</p>
 * 
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "files",
    "username"
})
public class SearchListFilesOutputPparams {

    @JsonProperty("files")
    private List<FileInfo> files;
    @JsonProperty("username")
    private String username;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("files")
    public List<FileInfo> getFiles() {
        return files;
    }

    @JsonProperty("files")
    public void setFiles(List<FileInfo> files) {
        this.files = files;
    }

    public SearchListFilesOutputPparams withFiles(List<FileInfo> files) {
        this.files = files;
        return this;
    }

    @JsonProperty("username")
    public String getUsername() {
        return username;
    }

    @JsonProperty("username")
    public void setUsername(String username) {
        this.username = username;
    }

    public SearchListFilesOutputPparams withUsername(String username) {
        this.username = username;
        return this;
    }

    @JsonAnyGetter
    public Map<String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperties(String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public String toString() {
        return ((((((("SearchListFilesOutputPparams"+" [files=")+ files)+", username=")+ username)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
