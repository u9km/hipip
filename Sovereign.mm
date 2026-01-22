#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import "dobby.h" // ⚠️ تأكد أن ملف dobby.h و libdobby.a مرفوعين بجانب هذا الملف

// ============================================================================
// [1] قائمة الأوفستات المصححة (تم إصلاحها لمنع الكراش)
// ============================================================================
static uintptr_t offsets[] = {
    0x2A8B68,   // تم التصحيح
    0x1C87200,  // تم التصحيح
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
    0x757D4,    // هذا الرقم كان 0x1000757D4 وتم إصلاحه
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
// هذه الدالة الفارغة ستعمل بدلاً من دوال الحماية الأصلية
void NullFunction() {
    return; 
}

// ============================================================================
// [3] المحرك الذكي (Smart Engine)
// ============================================================================
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
// [4] تنظيف الملفات المؤقتة
// ============================================================================
void CleanTempFiles() {
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ano_tmp"] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] error:nil];
}

// ============================================================================
// [5] نقطة البداية (التشغيل)
// ============================================================================
__attribute__((constructor))
static void InitSmartHook() {
    
    // 1. تنظيف فوري
    CleanTempFiles();

    // 2. الانتظار 5 ثواني لضمان تحميل اللعبة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        uintptr_t slide = GetBaseAddress("ShadowTrackerExtra");
        
        if (slide != 0) {
            int count = sizeof(offsets) / sizeof(offsets[0]);
            
            for (int i = 0; i < count; i++) {
                // المعادلة: العنوان الحقيقي = السلايد + الأوفست المصحح
                uintptr_t targetAddr = slide + offsets[i];
                
                // ⚡️ تفعيل Dobby Hook (آمن للسايدلود)
                DobbyHook((void *)targetAddr, (void *)NullFunction, NULL);
            }
            
            NSLog(@"[Sovereign] ✅ Dobby Hook Applied on %d offsets.", count);
            
            // رسالة صغيرة للتأكد أن التويك يعمل
            dispatch_async(dispatch_get_main_queue(), ^{
                UIWindow *win = [UIApplication sharedApplication].keyWindow;
                UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 200, 30)];
                lbl.text = @"Sovereign Active ✅";
                lbl.textColor = [UIColor greenColor];
                lbl.font = [UIFont boldSystemFontOfSize:14];
                [win addSubview:lbl];
                
                // إخفاء الرسالة بعد 4 ثواني
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [lbl removeFromSuperview];
                });
            });
        }
    });
}
