<template>
  <div id="login-view">
    <el-container>
      <el-header>
        <el-row>
          <el-col :span="12" :offset="6">
            <h1>登陆</h1>
          </el-col>
        </el-row>
      </el-header>
      <el-main>
        <el-row>
          <el-col :span="12" :offset="6">
            <el-form>
              <el-form-item label="Username">
                <el-input v-model="username"></el-input>
              </el-form-item>
              <el-form-item label="Password">
                <el-input v-model="password" show-password></el-input>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="login">Login</el-button>
              </el-form-item>
            </el-form>
          </el-col>
        </el-row>
      </el-main>
    </el-container>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "loginView",
  data() {
    return {
      username: "",
      password: "",
    };
  },
  methods: {
    login() {
      if (this.username === "" || this.password === "") {
        this.$message.error("用户名或密码不能为空");
        return;
      }
      axios
        .post("http://154.17.16.16:8080/api/login", {
          username: this.username,
          password: this.password,
        })
        .then((res) => {
          // save token to localStorage
          localStorage.setItem("token", res.data.token);
          this.$router.push("/index");
        })
        .catch((err) => {
          console.log(err);
          this.$message.error(
            err.response.data.error_code
              ? err.response.data.error_code
              : "请求失败"
          );
        });
    },
  },
};
</script>

<style scoped></style>
