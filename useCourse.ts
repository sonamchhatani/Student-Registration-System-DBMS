// 统一管理用户相关的请求
import request from "@/utils/request.ts";

//统一管理接口
enum URL{
    LIST_URL=`/project5_java/courses/all`,
    DELETE_URL = `/project5_java/courses/delete`,
    ADD_URL = `/project5_java/courses/add`,
}

export const getAllCourses = async ()=>{
    return await request<CourseModel.Course,API.ApiResult<CourseModel.Course>>({
        url:URL.LIST_URL,
        method:'GET',
    })
}

export const deleteCourse = async (data:CourseModel.Course)=>{
    console.log(data);
    return await request<any,API.ApiResult<any>>({
        url:URL.DELETE_URL,
        method:'POST',
        data:data
    })
}

export const addCourse = async (data:CourseModel.Course)=>{
    return await request<any,API.ApiResult<any>>({
        url:URL.ADD_URL,
        method:'POST',
        data:data
    })
}

// export const loginUser= async (data: UserModel.UserLoginDto)=>{
//     return await request<UserModel.UserLoginVo,API.ApiResult<UserModel.UserLoginVo>>({
//         url:URL.LOGIN_URL,
//         method:'POST',
//         data:data
//     })
// }
//
// export const userAdd = async (data: UserModel.UserAddDto) => {
//     return await request<boolean, API.ApiResult<boolean>>({
//         url: URL.ADD_URL,
//         method: 'POST',
//         data: data
//     })
// }
//
// export const userDelete = async (id: number) => {
//     return await request<boolean, API.ApiResult<boolean>>({
//         url: `/user/delete/${id}`,
//         method: 'DELETE'
//     })
// }
//
//
// export const userUpdate = async (data: UserModel.UserUpdateDto) => {
//     return await request<number, API.ApiResult<number>>({
//         url: `/user/update`,
//         method: 'POST',
//         data: data
//     })
// }
//
// export const userPage = async (data: UserModel.UserQueryDto) => {
//     return await request<API.ApiPage<UserModel.UserVo>, API.ApiResult<API.ApiPage<UserModel.UserVo>>>({
//         url: `/user/page`,
//         method: 'GET',
//         params: data
//     })
// }