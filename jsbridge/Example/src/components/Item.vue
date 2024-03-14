<script setup lang="ts">
import {defineEmits} from 'vue'

defineProps({
  title: {
    type: String,
    default: ''
  },
  custom: {
    type: Boolean,
    default: false
  }
})
const emits = defineEmits(['click'])

const handleClick = () => {
  emits('click')
}
</script>

<template>
  <div class="item">
    <button v-if="title" type='button' @click="handleClick()">{{title}}</button>
    <slot v-if="custom" />
  </div>
</template>

<style lang="scss" scoped>
.item {
  margin-bottom: 10px;
  width: 100%;
  background: #A7A7A7;
  border-radius: 10px;
  padding: 10px;
  box-sizing: border-box;

  button {
    width: 100%;
    font-size: 15px;
    border: none;
    background: #A7A7A7;
    border-radius: 10px;
  }

  .title {
    margin-top: 25px;
  }
}
</style>
