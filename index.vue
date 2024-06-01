<script setup lang="ts">


import {onMounted, ref} from "vue";
import {addStudent, getAllStudents} from "@/api/useStudent.ts";


const coursesList = ref();

onMounted(()=>{
    handleGetAllStudents();
})

const handleGetAllStudents=async ()=>{
    let res:API.ApiResult<CourseModel.Course[]> = await getAllStudents();
    coursesList.value=res.data;
    console.log(coursesList.value)
}

let timer:any;
const studentInfo=ref({} as StudentModel.Student);
const drawer = ref(false);
const dialog = ref(false)
const loading = ref(false)
const handleAdd = async ()=>{
    loading.value = true
    let res=await addStudent(studentInfo.value);
    if(res.code==200){
        console.log("success");
        loading.value = false
        dialog.value = false
        await handleGetAllStudents();
    }
}

const cancelForm = () => {
    loading.value = false
    dialog.value = false
    clearTimeout(timer)
}


</script>

<template>
    <el-button type="primary" style="margin-left: 16px;margin-top: 3vh;" @click="drawer = true">
        addStudent
    </el-button>
    <el-drawer v-model="drawer" title="Add a student" :with-header="false">
        <!--<span>Hi there!</span>-->
        <el-form :model="studentInfo" label-width="auto" style="max-width: 600px">
            <el-form-item label="B#" >
                <el-input v-model="studentInfo.b" autocomplete="off" />
            </el-form-item>
            <el-form-item label="firstName" >
                <el-input v-model="studentInfo.firstName" autocomplete="off" />
            </el-form-item>
            <el-form-item label="lastName" >
                <el-input v-model="studentInfo.lastName" autocomplete="off" />
            </el-form-item>
            <el-form-item label="stLevel" >
                <el-input v-model="studentInfo.stLevel" autocomplete="off" />
            </el-form-item>
            <el-form-item label="gpa" >
                <el-input v-model="studentInfo.gpa" autocomplete="off" />
            </el-form-item>
            <el-form-item label="email" >
                <el-input v-model="studentInfo.email" autocomplete="off" />
            </el-form-item>
            <el-form-item label="bdate" >
                <el-date-picker
                    v-model="studentInfo.bdate"
                    type="date"
                    placeholder="Pick a date"
                    style="width: 100%"
                />
            </el-form-item>
            <div class="demo-drawer__footer">
                <el-button @click="cancelForm">Cancel</el-button>
                <el-button type="primary" :loading="loading" @click="handleAdd">
                    {{ loading ? 'Submitting ...' : 'Submit' }}
                </el-button>
            </div>
        </el-form>
    </el-drawer>
    <el-table :data="coursesList" style="width: 100%;margin-top: 3vh">
        <el-table-column prop="firstName" label="firstName" width="180" />
        <el-table-column prop="lastName" label="lastName" width="180" />
        <el-table-column prop="stLevel" label="stLevel" />
        <el-table-column prop="gpa" label="gpa" />
        <el-table-column prop="email" label="email" />
        <el-table-column prop="bdate" label="bdate" />
        <el-table-column prop="b" label="B#" />
        <!--<el-table-column label="Operations" >-->
        <!--    <template #default="scope">-->
        <!--        <el-button-->
        <!--            size="small"-->
        <!--            type="danger"-->
        <!--        >-->
        <!--            Delete-->
        <!--        </el-button>-->
        <!--    </template>-->
        <!--</el-table-column>-->
    </el-table>
</template>

<style scoped>

</style>