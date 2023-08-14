<template>
  <div id="file-check">
    <el-container>
      <el-main>
        <el-row>
          <el-col :span="22" :offset="1">
            <h3>新增</h3>
            <el-button @click="newJob">新增</el-button>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="22" :offset="1">
            <el-divider></el-divider>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="22" :offset="1">
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
        </el-row>
        <el-row>
          <el-col :span="22" :offset="1">
            <el-divider></el-divider>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="22" :offset="1">
            <h3>选择数据</h3>
            <el-button @click="choseFile" :disabled="jobData.id !== 0"
              >选择文件
            </el-button>
            <h5>
              域名数量:
              {{
                jobData.domain_numb === 0
                  ? jobData.domains.length
                  : jobData.domain_numb
              }}
            </h5>
            <input
              type="file"
              ref="fileInput"
              style="display: none"
              @change="onFileChange"
            />
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="22" :offset="1">
            <el-divider></el-divider>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="22" :offset="1">
            <h3>任务进度</h3>
            <el-progress
              :text-inside="true"
              :stroke-width="24"
              :percentage="jobData.percentage"
              status="success"
            ></el-progress>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="22" :offset="1">
            <el-divider></el-divider>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="22" :offset="1">
            <h3>任务控制</h3>
            <el-button @click="addJob">提交</el-button>
            <el-button type="primary" @click="startJob">开始</el-button>
            <el-button type="info" @click="pausedJob">暂停</el-button>
            <el-button type="danger" @click="endJob">结束</el-button>
            <el-button type="success" @click="exportJob">下载结果</el-button>
            <el-button type="success" @click="viewJob">查看结果</el-button>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="22" :offset="1">
            <el-divider></el-divider>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="22" :offset="1">
            <h3>历史任务</h3>
            <el-table :data="jobHistory">
              <el-table-column prop="id" label="编号"></el-table-column>
              <el-table-column prop="created_at" label="创建时间" width="180">
                <template slot-scope="scope">
                  <span>{{
                    scope.row.created_at | moment("YYYY-MM-DD HH:mm:ss")
                  }}</span>
                </template>
              </el-table-column>
              <el-table-column
                prop="domain_numb"
                label="查询数"
              ></el-table-column>
              <el-table-column prop="job_model" label="模式"></el-table-column>
              <el-table-column prop="status" label="状态">
                <template slot-scope="scope">
                  <span v-if="scope.row.status === 1">未开始</span>
                  <span v-else-if="scope.row.status === 2">进行中</span>
                  <span v-else-if="scope.row.status === 3">暂停</span>
                  <span v-else-if="scope.row.status === 4">已完成</span>
                </template>
              </el-table-column>
              <el-table-column label="操作" width="280">
                <template slot-scope="scope">
                  <el-button
                    size="small"
                    type="primary"
                    icon="el-icon-refresh"
                    @click="changeJob(scope.row)"
                    >切换
                  </el-button>
                  <el-button
                    size="small"
                    type="danger"
                    icon="el-icon-delete"
                    @click="deleteJob(scope.row)"
                    >删除
                  </el-button>
                </template>
              </el-table-column>
            </el-table>
            <el-pagination
              :page-size="10"
              :total="jobCount"
              layout="prev, pager, next"
              @current-change="changePage"
            ></el-pagination>
          </el-col>
        </el-row>
      </el-main>
    </el-container>
    <domain-dialog ref="domainDialog" :job-data="jobData"></domain-dialog>
  </div>
</template>

<script>
import axios from "axios";
import FileSaver from "file-saver";
import DomainDialog from "@/components/domainDialog.vue";

export default {
  name: "fileCheck",
  components: { DomainDialog },
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
      models: ["DNS", "Whois", "WhoisNoProxy"],
      page: 1,
      jobHistory: [],
      jobCount: 0,
    };
  },
  methods: {
    newJob() {
      this.jobData = {
        id: 0,
        jobModel: "",
        domains: [],
        percentage: 0,
      };
      this.$forceUpdate();
      this.cleanJobProcess();
    },
    addJob() {
      if (this.jobData.id !== 0) {
        this.$message.error("任务已经开始");
        return;
      }
      if (this.jobData.jobModel === "") {
        this.$message.error("请选择任务模式");
        return;
      }
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
          this.page = 1;
          this.getJobList();
          this.$forceUpdate();
          this.lock = false;
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
    startJob() {
      if (this.jobData.id === 0) {
        this.$message.error("请先创建任务或切换任务");
        return;
      }
      if (this.jobData.status !== 1 && this.jobData.status !== 3) {
        this.$message.error("任务已经开始或结束");
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
          this.getJobList();
          this.$forceUpdate();
          this.doJobProcess();
          this.lock = false;
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
    pausedJob() {
      if (this.jobData.id === 0) {
        this.$message.error("请先创建任务或切换任务");
        return;
      }
      if (this.jobData.status !== 2) {
        this.$message.error("任务已经未开始");
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
          "http://154.17.16.16:8080/api/job/paused",
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
          this.getJobList();
          this.$forceUpdate();
          this.lock = false;
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
    endJob() {
      if (this.jobData.id === 0) {
        this.$message.error("请先创建任务或切换任务");
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
          "http://154.17.16.16:8080/api/job/end",
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
          this.getJobList();
          this.$forceUpdate();
          this.lock = false;
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
    viewJob() {
      this.$refs.domainDialog.openDialog();
    },
    exportJob() {
      if (this.jobData.id === 0) {
        this.$message.error("请先创建任务或切换任务");
        return;
      }
      if (this.jobData.status !== 4) {
        this.$message.error("任务未结束");
        return;
      }
      if (this.lock) {
        this.$message.error("其他请求处理中");
        return;
      }
      this.lock = true;
      axios
        .post(
          "http://154.17.16.16:8080/api/job/export",
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
          let blob = new Blob([res.data], { type: "application/octet-stream" });
          FileSaver.saveAs(blob, `job_${this.jobData.id}.csv`);
          this.lock = false;
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
    changeJobModel() {
      this.$forceUpdate();
    },
    changeJob(jobData) {
      this.jobData = {
        id: jobData.id,
        jobModel: jobData.job_model,
        domains: [],
        domain_numb: jobData.domain_numb,
        percentage: 0,
        status: jobData.status,
      };
      this.$forceUpdate();
      this.doJobProcess();
      if (jobData.status === 4) {
        setTimeout(() => {
          this.cleanJobProcess();
        }, 6000);
      }
    },
    deleteJob(jobData) {
      if (jobData.status !== 1 && jobData.status !== 4) {
        this.$message.error("任务已经开始或结束");
        return;
      }
      axios
        .post(
          "http://154.17.16.16:8080/api/job/delete",
          {
            id: jobData.id,
          },
          {
            headers: {
              Token: this.token,
            },
          }
        )
        .then(() => {
          this.page = 1;
          this.getJobList();
        })
        .catch((err) => {
          this.$message.error(
            err.response.data.error_code
              ? err.response.data.error_code
              : "请求失败"
          );
        });
    },
    choseFile() {
      this.$refs.fileInput.click();
    },
    onFileChange(event) {
      let file = event.target.files[0];
      let reader = new FileReader();

      reader.onload = () => {
        this.jobData.domains = [];
        let domains = reader.result.split("\n");
        for (let i = 0; i < domains.length; i++) {
          let domain = domains[i];
          if (domain !== "") {
            domain = domain.trim();
            domain = domain.replace("/r", "");
            this.jobData.domains.push(domain);
          }
        }
        this.$forceUpdate();
      };

      reader.readAsText(file);
    },
    changePage(page) {
      this.page = page;
      this.getJobList();
    },
    getJobList() {
      axios
        .get(
          `http://154.17.16.16:8080/api/job/list?page=${this.page}&page_size=10`,
          {
            headers: {
              Token: this.token,
            },
          }
        )
        .then((res) => {
          this.jobHistory = res.data.data;
          this.jobCount = res.data.count;
          this.$forceUpdate();
        })
        .catch((err) => {
          this.$message.error(
            err.response.data.error_code
              ? err.response.data.error_code
              : "请求失败"
          );
        });
    },
  },
  mounted() {
    // get token from localStorage
    this.token = localStorage.getItem("token");
    if (this.token === null) {
      this.$router.push("/login");
      return;
    }
    this.getJobList();
  },
};
</script>
