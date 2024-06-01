// 统一管理用户相关的请求
import request from "@/utils/request.ts";

//统一管理接口
enum URL{
    LIST_URL=`/project5_java/classes/all`,
    DELETE_URL = `/project5_java/classes/delete`,
    ADD_URL = `/project5_java/classes/add`,
}

export const getAllClasses= async ()=>{
    return await request<ClassModel.Class,API.ApiResult<ClassModel.Class>>({
        url:URL.LIST_URL,
        method:'GET',
    })
}

export const deleteClasses = async (data:ClassModel.Class)=>{
    console.log(data);
    return await request<any,API.ApiResult<any>>({
        url:URL.DELETE_URL,
        method:'POST',
        data:data
    })
}

export const addClass = async (data:ClassModel.Class)=>{
    return await request<any,API.ApiResult<any>>({
        url:URL.ADD_URL,
        method:'POST',
        data:data
    })
}

