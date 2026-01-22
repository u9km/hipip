#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import "dobby.h" // ⚠️ تأكد أن dobby.h و libdobby.a موجودين في المستودع

// ============================================================================
// [1] قائمة الأوفستات الجديدة (36 أوفست)
// ============================================================================
static uintptr_t offsets[] = {
    0x1C84770,
    0x1C87200,
    0x1C85C80,
    0x1C86DF0,
    0x1C851DC,
    0x1947E04,
    0x1948928,
    0xC8293C,
    0x1C42B90,
    0x1C427F0,
    0x1C41C70,
    0x1C3F988,
    0x15C7284,
    0x5A47DC,
    0x1C80474,
    0x1C80710,
    0x93AE94,
    0x93F9A8,
    0x1938A10,
    0x193821C,
    0x1936D54,
    0x193504C,
    0xC82804,
    0xC827B8,
    0xC8270C,
    0xC81304,
    0xC80DD4,
    0xC80744,
    0x757D4,
    0x7559C,
    0x75378,
    0x7599C,
    0x1C86920,
    0x1C83A10,
    0x1C88F30,
    0x1C87B00
};

// ============================================================================
// [2] دالة التعطيل (Null Function)
// ============================================================================
// هذه الدالة لا تفعل شيئاً (Return Void)، وهي بديلة آمنة لـ RET
void NullFunction() {
    return;
}

// ============================================================================
// [3] المحرك (جلب عنوان الذاكرة الحقيقي)
// ============================================================================
static const struct mach_header_64* GetImageHeader(const char *target) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, target)) {
            // نرجع عنوان بداية الملف في الذاكرة (Header Address)
            return (const struct mach_header_64*)_dyld_get_image_header(i);
        }
    }
    return NULL;
}

// ============================================================================
// [4] تنظيف الملفات (لتحسين الأداء)
// ============================================================================
void CleanTempFiles() {
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ano_tmp"] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] error:nil];
}

// ============================================================================
// [5] نقطة التشغيل (Main Entry)
// ============================================================================
__attribute__((constructor))
static void InitSovereign() {
    
    // 1. تنظيف فوري عند الفتح
    CleanTempFiles();

    // 2. تأخير 5 ثواني لضمان تحميل اللعبة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // البحث عن اللعبة
        const struct mach_header_64* header = GetImageHeader("ShadowTrackerExtra");
        
        if (header != NULL) {
            uintptr_t baseAddr = (uintptr_t)header;
            int count = sizeof(offsets) / sizeof(offsets[0]);
            
            // حلقة تكرارية لتطبيق DobbyHook على القائمة
            for (int i = 0; i < count; i++) {
                // المعادلة: بداية الذاكرة + الأوفست
                uintptr_t targetAddr = baseAddr + offsets[i];
                
                // التفعيل الآمن (بدون كراش)
                DobbyHook((void *)targetAddr, (void *)NullFunction, NULL);
            }
            
            NSLog(@"[Sovereign] ✅ Hooks Applied Successfully on %d functions.", count);
            
            // رسالة صغيرة (اختياري)
            dispatch_async(dispatch_get_main_queue(), ^{
                UIWindow *win = [UIApplication sharedApplication].keyWindow;
                UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 200, 30)];
                lbl.text = @"Active ✅"; 
                lbl.textColor = [UIColor greenColor];
                lbl.font = [UIFont boldSystemFontOfSize:14];
                [win addSubview:lbl];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [lbl removeFromSuperview];
                });
            });
        }
    });
}
