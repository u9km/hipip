#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>       // ضروري جداً لعمل dladdr
#import "dobby.h"       // تأكد أن dobby.h و libdobby.a بجانب الملف

// ============================================================================
// [1] القائمة الذهبية للأوفستات (تم تحويلها لـ RVA)
// ============================================================================
static uintptr_t offsets[] = {
    0x2A8B68,   0x1C84770,  0x1C87200,  0x1C85C80,  0x1C86DF0, 
    0x1C851DC,  0x1947E04,  0x1948928,  0xC8293C,   0x1C42B90, 
    0x1C427F0,  0x1C41C70,  0x1C3F988,  0x15C7284,  0x5A47DC,  
    0x1C80474,  0x1C80710,  0x93AE94,   0x93F9A8,   0x1938A10, 
    0x193821C,  0x1936D54,  0x193504C,  0xC82804,   0xC827B8,  
    0xC8270C,   0xC81304,   0xC80DD4,   0xC80744,   0x757D4,   
    0x7559C,    0x75378,    0x7599C,    0x1C86920,  0x1C83A10, 
    0x1C88F30,  0x1C87B00
};

// ============================================================================
// [2] دالة الباتش الآمن (Safe Patch)
// ============================================================================
void ApplyPatch(uintptr_t addr) {
    // كود RET (Little Endian ARM64) = "عد فوراً ولا تفعل شيئاً"
    uint8_t patch[] = {0xC0, 0x03, 0x5F, 0xD6};
    
    // DobbyCodePatch يتولى فتح حماية الذاكرة والكتابة بأمان
    DobbyCodePatch((void *)addr, patch, 4);
}

// ============================================================================
// [3] صياد المكتبات (The Hunter)
// ============================================================================
static void LibraryLoadedHook(const struct mach_header* header, intptr_t slide) {
    
    Dl_info info;
    // التأكد من اسم المكتبة التي تم تحميلها الآن
    if (dladdr(header, &info) && info.dli_fname) {
        
        // هل هي ShadowTrackerExtra؟
        if (strstr(info.dli_fname, "ShadowTrackerExtra")) {
            
            // نعم! تم الإمساك بها
            uintptr_t baseAddr = (uintptr_t)header;
            int count = sizeof(offsets) / sizeof(offsets[0]);
            
            // تطبيق الباتش على كل الأوفستات
            for (int i = 0; i < count; i++) {
                uintptr_t target = baseAddr + offsets[i];
                ApplyPatch(target);
            }
            
            NSLog(@"[Sovereign] ⚡️ Target found & patched (%d offsets).", count);

            // إظهار رسالة نجاح على الشاشة
            dispatch_async(dispatch_get_main_queue(), ^{
                // جلب النافذة بطريقة تدعم iOS 13+
                UIWindow *window = nil;
                for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                    if (scene.activationState == UISceneActivationStateForegroundActive) {
                        for (UIWindow *w in scene.windows) {
                            if (w.isKeyWindow) { window = w; break; }
                        }
                    }
                }
                
                if (window) {
                    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 250, 30)];
                    lbl.text = @"Sovereign Active ⚡️";
                    lbl.textColor = [UIColor cyanColor];
                    lbl.font = [UIFont boldSystemFontOfSize:16];
                    lbl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
                    lbl.textAlignment = NSTextAlignmentCenter;
                    lbl.layer.cornerRadius = 5;
                    lbl.clipsToBounds = YES;
                    [window addSubview:lbl];
                    
                    // إخفاء الرسالة بعد 5 ثواني
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
static void InitFinal() {
    // تنظيف المخلفات
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ano_tmp"] error:nil];
    
    // تسجيل دالة الصيد (تعمل تلقائياً عند تحميل اللعبة)
    _dyld_register_func_for_add_image(LibraryLoadedHook);
}
