#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import "dobby.h" // أبقِ الملفات كما هي

// ============================================================================
// [1] الأوفستات (موجودة ولكن لن نفعلها بقوة لمنع الكراش)
// ============================================================================
static uintptr_t offsets[] = {
    0x0002A8B68, 0x1002A8B68, 0x101C87200, 0x101C85C80
    // ... (باقي القائمة)
};

// ============================================================================
// [2] دوال مساعدة (للتنظيف والواجهة)
// ============================================================================
void CleanTemp() {
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ano_tmp"] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] error:nil];
}

static uintptr_t GetBaseAddress(const char *target) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, target)) {
            return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

// ============================================================================
// [3] نقطة التشغيل (بدون كراش)
// ============================================================================
__attribute__((constructor))
static void InitSafeMode() {
    
    // 1. تنظيف الملفات
    CleanTemp();
    
    // 2. تشغيل بعد 5 ثواني
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // إظهار رسالة "تم التشغيل" لتعرف أن الأداة تعمل
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sovereign"
                                                                       message:@"Tool Active (Safe Mode)\nCleaning Done."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        
        // البحث عن العنوان (فقط طباعة، بدون تعديل لمنع الكراش)
        uintptr_t slide = GetBaseAddress("ShadowTrackerExtra");
        if (slide != 0) {
            NSLog(@"[Sovereign] Base Found: %lx", slide);
            
            // ⚠️ ملاحظة: تم إيقاف DobbyHook هنا لأنه هو سبب الكراش
            // إذا كنت تريد تفعيله، يجب أن يكون لديك جيلبريك أو أوفستات مختلفة
            // DobbyHook(...) <--- معطل للأمان
        }
    });
}
