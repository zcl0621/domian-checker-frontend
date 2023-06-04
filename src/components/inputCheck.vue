<template>
  <div id="input-check">
    <el-container>
      <el-main>
        <el-row>
          <el-col :span="10" :offset="1">
            <h3>查询模式</h3>
            <el-radio-group
              v-model="jobData.jobModel"
              :disabled="jobData.id !== 0"
              @change="changeJobModel"
            >
              <el-radio-button
                v-for="(iterm, key) in models"
                :label="iterm"
                :key="key"
                >{{ iterm }}
              </el-radio-button>
            </el-radio-group>
          </el-col>
          <el-col :span="10" :offset="2">
            <h3>输入数据</h3>
            <el-input
              type="textarea"
              :autosize="{ minRows: 10, maxRows: 40 }"
              placeholder="请输入内容"
              v-model="input_domains"
              :disabled="jobData.id !== 0"
            >
            </el-input>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="22" :offset="1">
            <el-button type="primary" @click="startJob">开始</el-button>
          </el-col>
        </el-row>

        <el-row>
          <el-col :span="22" :offset="1">
            <el-divider></el-divider>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="22" :offset="1">
            <h3>任务明细</h3>
            <el-table :data="domainArray" v-if="jobData.jobModel === 'DNS'">
              <el-table-column prop="domain" label="域"></el-table-column>
              <el-table-column
                prop="name_servers"
                label="服务器"
              ></el-table-column>
              <el-table-column prop="r_code" label="结果">
                <template slot-scope="scope">
                  <span v-if="scope.row.r_code === ''">未知</span>
                  <span v-else>{{ scope.row.r_code }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="checked" label="状态">
                <template slot-scope="scope">
                  <span v-if="scope.row.checked === 'true'">taken</span>
                  <span v-else>free</span>
                </template>
              </el-table-column>
            </el-table>
            <el-table
              :data="domainArray"
              v-else-if="jobData.jobModel === 'Whois'"
            >
              <el-table-column prop="domain" label="域"></el-table-column>
              <el-table-column
                prop="whois_name_servers"
                label="服务器"
              ></el-table-column>
              <el-table-column
                prop="whois_created_date"
                label="创建时间"
              ></el-table-column>
              <el-table-column
                prop="whois_expiration_date"
                label="过期时间"
              ></el-table-column>
              <el-table-column
                prop="whois_status"
                label="状态"
              ></el-table-column>
            </el-table>
            <el-table :data="domainArray" v-else>
              <el-table-column prop="domain" label="域"></el-table-column>
              <el-table-column
                prop="name_servers"
                label="服务器"
              ></el-table-column>
              <el-table-column prop="r_code" label="结果">
                <template slot-scope="scope">
                  <span v-if="scope.row.r_code === ''">未知</span>
                  <span v-else>{{ scope.row.r_code }}</span>
                </template>
              </el-table-column>
              <el-table-column prop="checked" label="状态">
                <template slot-scope="scope">
                  <span v-if="scope.row.checked === 'true'">taken</span>
                  <span v-else>free</span>
                </template>
              </el-table-column>
              <el-table-column
                prop="whois_name_servers"
                label="Whois服务器"
              ></el-table-column>
              <el-table-column
                prop="whois_created_date"
                label="Whois创建时间"
              ></el-table-column>
              <el-table-column
                prop="whois_expiration_date"
                label="Whois过期时间"
              ></el-table-column>
              <el-table-column
                prop="whois_status"
                label="Whois状态"
              ></el-table-column>
            </el-table>
            <el-pagination
              background
              layout="prev, pager, next"
              :total="count"
              :page-size="pageSizes"
              @current-change="handleCurrentChange"
            >
            </el-pagination>
          </el-col>
        </el-row>
      </el-main>
    </el-container>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "inputCheck",
  data() {
    return {
      lock: false,
      jobData: {
        id: 0,
        jobModel: "",
        domain_numb: 0,
        domains: [],
        percentage: 0,
        status: 0,
      },
      models: ["DNS", "Whois", "混合"],
      page: 1,
      input_domains: "",
      domainArray: [],
      pageSizes: 200,
      count: 0,
      currentPage: 1,
    };
  },
  methods: {
    startJob() {
      if (this.jobData.id !== 0) {
        this.$message.error("任务已经开始");
        return;
      }
      if (this.jobData.jobModel === "") {
        this.$message.error("请选择任务模式");
        return;
      }
      this.getInputDomain();
      if (this.jobData.domains.length === 0) {
        this.$message.error("请上传数据");
        return;
      }
      this.cleanJobProcess();
      if (this.lock) {
        this.$message.error("其他请求处理中");
        return;
      }
      this.lock = true;
      axios
        .post(
          "http://154.17.16.16:8080/api/job/add",
          {
            job_model: this.jobData.jobModel,
            domains: this.jobData.domains,
          },
          {
            headers: {
              Token: this.token,
            },
          }
        )
        .then((res) => {
          this.jobData.id = res.data.id;
          this.jobData.status = res.data.status;
          axios
            .post(
              "http://154.17.16.16:8080/api/job/start",
              {
                id: this.jobData.id,
              },
              {
                headers: {
                  Token: this.token,
                },
              }
            )
            .then((res) => {
              this.jobData.id = res.data.id;
              this.jobData.status = res.data.status;
              this.page = 1;
              this.doJobProcess();
              this.lock = false;
              this.$forceUpdate();
            })
            .catch((err) => {
              this.$message.error(
                err.response.data.error_code
                  ? err.response.data.error_code
                  : "请求失败"
              );
              this.lock = false;
            });
        })
        .catch((err) => {
          this.$message.error(
            err.response.data.error_code
              ? err.response.data.error_code
              : "请求失败"
          );
          this.lock = false;
        });
    },
    doJobProcess() {
      if (this.jobTicker) {
        clearInterval(this.jobTicker);
      }
      this.jobTicker = setInterval(() => {
        this.jobProcess();
      }, 5000);
    },
    cleanJobProcess() {
      if (this.jobTicker) {
        clearInterval(this.jobTicker);
      }
    },
    jobProcess() {
      if (this.jobData.id === 0) {
        this.$message.error("请先创建任务或切换任务");
        return;
      }
      axios
        .post(
          "http://154.17.16.16:8080/api/job/process",
          {
            id: this.jobData.id,
          },
          {
            headers: {
              Token: this.token,
            },
          }
        )
        .then((res) => {
          if (this.jobData.percentage !== res.data.process) {
            this.getDomain();
          }
          this.jobData.percentage = res.data.process;
          this.$forceUpdate();
          if (res.data.process === 100) {
            clearInterval(this.jobTicker);
          }
        })
        .catch((err) => {
          this.$message.error(
            err.response.data.error_code
              ? err.response.data.error_code
              : "请求失败"
          );
        });
    },
    getInputDomain() {
      this.jobData.domains = [];
      let domains = this.input_domains.split("\n");
      for (let i = 0; i < domains.length; i++) {
        let domain = domains[i];
        if (domain !== "") {
          // check domain is valid
          if (domain.match(/^[a-zA-Z0-9-]{1,63}(\.[a-zA-Z0-9-]{1,63})+$/)) {
            domain = domain.trim();
            domain = domain.replace("/r", "");
            this.jobData.domains.push(domain);
          }
        }
      }
      this.$forceUpdate();
    },
    getDomain() {
      axios
        .post(
          "http://154.17.16.16:8080/api/domain/list",
          {
            page: this.currentPage,
            page_size: this.pageSizes,
            job_id: this.jobData.id,
            sort: "id",
          },
          {
            headers: {
              Token: this.token,
            },
          }
        )
        .then((res) => {
          this.count = res.data.count;
          this.domainArray = res.data.data;
          this.$forceUpdate();
        })
        .catch((err) => {
          this.$message.error(
            err.response.data.error_code
              ? err.response.data.error_code
              : "请求失败"
          );
          this.lock = false;
        });
    },
    handleCurrentChange(val) {
      this.currentPage = val;
      this.getDomain();
    },
    changeJobModel() {
      this.$forceUpdate();
    },
  },
  mounted() {
    // get token from localStorage
    this.token = localStorage.getItem("token");
    if (this.token === null) {
      this.$router.push("/login");
    }
  },
};
</script>
