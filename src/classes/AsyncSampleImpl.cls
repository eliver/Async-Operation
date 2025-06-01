/**
 * Created by Eric Liang on 2019/9/30.
 */

public with sharing class AsyncSampleImpl implements IAsyncOperation {
    public String execute(String JSONString) {
        return 'success';
    }
}