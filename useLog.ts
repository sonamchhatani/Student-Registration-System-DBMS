// 统一管理用户相关的请求
import request from "@/utils/request.ts";

//统一管理接口
enum URL{
    LIST_URL=`/project5_java/logs/all`,
}

export const getAllLogs= async ()=>{
    return await request<LogModel.Log,API.ApiResult<LogModel.Log>>({
        url:URL.LIST_URL,
        method:'GET',
    })
}
