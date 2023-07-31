<template>
  <div id="domain-dialog">
    <el-dialog
      title="任务详情"
      :visible.sync="dialogTableVisible"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
      width="80%"
    >
      <el-table :data="domainArray">
        <el-table-column prop="domain" label="域"></el-table-column>
        <el-table-column prop="whois_name_servers" label="DNS">
          <template slot-scope="scope">
            <span
              v-if="
                scope.row.name_servers != '' &&
                scope.row.whois_name_servers != ''
              "
              >{{ scope.row.name_servers + scope.row.whois_name_servers }}</span
            >
            <span v-else-if="scope.row.name_servers != ''">{{
              scope.row.name_servers
            }}</span>
            <span v-else-if="scope.row.whois_name_servers != ''">{{
              scope.row.whois_name_servers
            }}</span>
            <span v-else>无</span>
          </template>
        </el-table-column>
        <el-table-column label="状态">
          <template slot-scope="scope">
            <span v-if="scope.row.checked === 'true'">taken</span>
            <span v-else>free</span>
          </template>
        </el-table-column>
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
    </el-dialog>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "domainDialog",
  data() {
    return {
      token: "",
      lock: false,
      dialogTableVisible: false,
      domainArray: [],
      pageSizes: 10,
      count: 0,
      currentPage: 1,
    };
  },
  props: {
    jobId: Number,
    jobData: Object,
  },
  methods: {
    openDialog() {
      this.dialogTableVisible = true;
      this.getDomain();
    },
    handleCurrentChange(val) {
      this.currentPage = val;
      this.getDomain();
    },
    getDomain() {
      if (this.lock) {
        return;
      }
      this.lock = true;
      axios
        .post(
          "http://154.17.16.16:8080/api/domain/list",
          {
            page: this.currentPage,
            page_size: this.pageSizes,
            job_id: this.jobData.id,
            sort: "id desc",
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
  },
  mounted() {
    this.token = localStorage.getItem("token");
  },
};
</script>
