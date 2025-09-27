import type { Router } from 'vue-router';
import { useAppStore } from '/@/store/modules/app';
import { useMultipleTabStore } from '/@/store/modules/multipleTab';
import { useUserStore } from '/@/store/modules/user';
import { usePermissionStore } from '/@/store/modules/permission';
import { PageEnum } from '/@/enums/pageEnum';
import { removeTabChangeListener } from '/@/logics/mitt/routeChange';
import { emitPasswordChangeRequired } from '/@/logics/mitt/passwordChange';

export function createStateGuard(router: Router) {
  router.afterEach((to) => {
    // Just enter the login page and clear the authentication information
    if (to.path === PageEnum.BASE_LOGIN) {
      const tabStore = useMultipleTabStore();
      const userStore = useUserStore();
      const appStore = useAppStore();
      const permissionStore = usePermissionStore();
      appStore.resetAllState();
      permissionStore.resetState();
      tabStore.resetState();
      userStore.resetState();
      removeTabChangeListener();
    }

    // Check if we need to show the password change modal on every route change
    const needChangePassword = localStorage.getItem('needChangePassword');
    const tempUsername = localStorage.getItem('temp_username');

    console.log('Checking for password change requirement:', { needChangePassword, tempUsername, toPath: to.path });

    if (needChangePassword === 'true' && tempUsername) {
      console.log('Emitting password change required event');
      // Emit event to show password change modal
      emitPasswordChangeRequired();
    }
  });
}
