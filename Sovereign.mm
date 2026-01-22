#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>       // ✅ تم إضافتها لحل مشكلة Dl_info
#import "dobby.h"       // تأكد أن هذا الملف موجود

// ============================================================================
// [1] قائمة الأوفستات (RVA - Clean)
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
// [2] دالة الباتش (باستخدام Dobby فقط)
// ============================================================================
// ملاحظة: DobbyCodePatch يقوم داخلياً بمعالجة حماية الذاكرة (mprotect/vm_remap)
// لذا لا داعي لاستدعاء mach_vm_protect يدوياً وتكسير البناء
void ApplyPatch(uintptr_t addr) {
    // كود RET (Little Endian ARM64)
    uint8_t patch[] = {0xC0, 0x03, 0x5F, 0xD6};
    
    // تطبيق الباتش
    DobbyCodePatch((void *)addr, patch, 4);
}

// ============================================================================
// [3] المراقب الذكي (Image Loader Callback)
// ============================================================================
// هذه الدالة تعمل تلقائياً عند تحميل أي مكتبة في اللعبة
static void LibraryLoadedHook(const struct mach_header* header, intptr_t slide) {
    
    // استخدام dladdr للتأكد من اسم المكتبة الحالية
    Dl_info info;
    if (dladdr(header, &info) && info.dli_fname) {
        
        // هل المكتبة هي ShadowTrackerExtra؟
        if (strstr(info.dli_fname, "ShadowTrackerExtra")) {
            
            // نعم! تم صيد اللعبة لحظة التشغيل
            uintptr_t baseAddr = (uintptr_t)header;
            int count = sizeof(offsets) / sizeof(offsets[0]);
            
            // تطبيق الباتش فوراً
            for (int i = 0; i < count; i++) {
                uintptr_t target = baseAddr + offsets[i];
                ApplyPatch(target);
            }
            
            NSLog(@"[Sovereign] ⚡️ ShadowTrackerExtra found & patched (%d offsets).", count);

            // إظهار رسالة (تعمل على كل الإصدارات)
            dispatch_async(dispatch_get_main_queue(), ^{
                // طريقة آمنة لجلب النافذة (بدون keyWindow القديمة)
                UIWindow *window = nil;
                for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                    if (scene.activationState == UISceneActivationStateForegroundActive) {
                        for (UIWindow *w in scene.windows) {
                            if (w.isKeyWindow) {
                                window = w;
                                break;
                            }
                        }
                    }
                }
                // احتياط للنسخ القديمة
                if (!window) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    window = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
                }

                if (window) {
                    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 300, 30)];
                    lbl.text = @"Sovereign Active | Force Mode ⚡️";
                    lbl.textColor = [UIColor greenColor];
                    lbl.font = [UIFont boldSystemFontOfSize:14];
                    lbl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
                    [window addSubview:lbl];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [lbl removeFromSuperview];
                    });
                }
            });
        }
    }
}

// ============================================================================
// [4] نقطة البداية (Constructor)
// ============================================================================
__attribute__((constructor))
static void InitForce() {
    // تنظيف
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ano_tmp"] error:nil];
    
    // تسجيل الدالة لمراقبة تحميل المكتبات
    _dyld_register_func_for_add_image(LibraryLoadedHook);
}
