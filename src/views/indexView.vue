<template>
  <div id="index-view">
    <el-row>
      <el-col :span="20" :offset="2">
        <el-tabs v-model="activeName">
          <el-tab-pane label="fileCheck" name="fileCheck">
            <file-check></file-check>
          </el-tab-pane>
          <el-tab-pane label="inputCheck" name="inputCheck">
            <input-check></input-check>
          </el-tab-pane>
        </el-tabs>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import FileCheck from "@/components/fileCheck.vue";
import InputCheck from "@/components/inputCheck.vue";

export default {
  name: "indexView",
  components: { InputCheck, FileCheck },
  data() {
    return {
      activeName: "fileCheck",
    };
  },
  methods: {},
};
</script>

<style scoped></style>
