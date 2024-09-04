<template>
  <div>
    <el-button type="primary" @click="handleClick">
      <i class="el-icon-menu"></i>
      <span>菜单</span>
    </el-button>
    <div>{{getTest('c') ? '在哦' : '不在'}}</div>
    <div v-if="getTest('c')">{{'在哦'}}</div>
    <div v-else>{{'不在'}}</div>
  </div>
</template>

<script lang="ts">
export default {
  setup() {
    let map = ref(new Map([['a', 1], ['b', 2]]))
    console.log("======>", map)
    const getTest = (key) => {
      console.log("======>", key)
      // console.log('key | value', key, map?.value.get(key))
      return map?.value.get(key)
    }

    const handleClick = () => {
      console.log('click')
      map?.value.set('c', 3)
    }

    return {
      getTest,
      handleClick
    }
  }
}
</script>

<style lang="less" scoped>

</style>