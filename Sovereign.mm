#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <mach/mach_vm.h> // مكتبة أقوى
#import "dobby.h"

// ============================================================================
// [1] القائمة
// ============================================================================
static uintptr_t offsets[] = {
    0x1C84770, 0x1C87200, 0x1C85C80, 0x1C86DF0, 0x1C851DC, 
    0x1947E04, 0x1948928, 0xC8293C,  0x1C42B90, 0x1C427F0, 
    0x1C41C70, 0x1C3F988, 0x15C7284, 0x5A47DC,  0x1C80474, 
    0x1C80710, 0x93AE94,  0x93F9A8,  0x1938A10, 0x193821C, 
    0x1936D54, 0x193504C, 0xC82804,  0xC827B8,  0xC8270C, 
    0xC81304,  0xC80DD4,  0xC80744,  0x757D4,   0x7559C, 
    0x75378,   0x7599C,   0x1C86920, 0x1C83A10, 0x1C88F30, 
    0x1C87B00
};

// ============================================================================
// [2] دالة الباتش الإجباري (Force Patch)
// ============================================================================
void ForcePatch(uintptr_t addr) {
    // كود RET
    uint8_t patch[] = {0xC0, 0x03, 0x5F, 0xD6};
    
    // 1. استخدام mach_vm_protect لفك الحماية بالقوة
    kern_return_t err = mach_vm_protect(mach_task_self(), 
                                        (mach_vm_address_t)addr, 
                                        4, 
                                        0, 
                                        VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    
    if (err == KERN_SUCCESS) {
        // 2. الكتابة المباشرة
        DobbyCodePatch((void *)addr, patch, 4);
        
        // 3. إعادة الحماية (Execute) لكي لا يحدث كراش عند التشغيل
        mach_vm_protect(mach_task_self(), (mach_vm_address_t)addr, 4, 0, VM_PROT_READ | VM_PROT_EXECUTE);
    } else {
        // طباعة الخطأ في الكونسول لتعرف السبب
        NSLog(@"[Sovereign] ❌ Failed to unlock memory at %lx. Error: %d", addr, err);
    }
}

// ============================================================================
// [3] المراقب الذكي (Image Loader Callback)
// ============================================================================
// هذه الدالة يتم استدعاؤها تلقائياً من النظام لكل مكتبة يتم تحميلها
static void LibraryLoadedHook(const struct mach_header* header, intptr_t slide) {
    // اسم المكتبة الحالية
    const char *path = _dyld_get_image_name(0); // نحتاج طريقة للتأكد من الهيدر الحالي
    
    // بما أن الـ callback يعطينا الهيدر، نبحث عن اسمه
    Dl_info info;
    if (dladdr(header, &info) && info.dli_fname) {
        if (strstr(info.dli_fname, "ShadowTrackerExtra")) {
            
            NSLog(@"[Sovereign] 🎯 ShadowTrackerExtra Detected at: %p", header);
            
            uintptr_t baseAddr = (uintptr_t)header;
            int count = sizeof(offsets) / sizeof(offsets[0]);
            
            for (int i = 0; i < count; i++) {
                uintptr_t target = baseAddr + offsets[i];
                ForcePatch(target);
            }
            
            // إظهار رسالة فورية
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sovereign"
                                                                               message:@"Offsets Applied via Force Patch."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            });
        }
    }
}

// ============================================================================
// [4] نقطة البداية
// ============================================================================
__attribute__((constructor))
static void InitForce() {
    // التسجيل في النظام لمراقبة تحميل المكتبات
    // هذا يضمن أننا نصطاد اللعبة فور تشغيلها
    _dyld_register_func_for_add_image(LibraryLoadedHook);
}
