/// <reference types="vite/client" />
//noinspection JSUnusedGlobalSymbols

declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<{}, {}, any>
  export default component
}
