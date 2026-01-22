#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <sys/mman.h>
#import "dobby.h" // تأكد أن الملفات مرفوعة

// ============================================================================
// [1] قائمة الأوفستات (الجديدة التي أرسلتها)
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
// [2] المحرك (جلب عنوان الذاكرة الحقيقي)
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
// [3] الباتش الاحترافي (Memory Patch)
// ============================================================================
// بدلاً من الهوك، نستخدم هذه الدالة لكتابة كود RET مباشرة
void ApplySafePatch(uintptr_t address) {
    // كود RET لمعالجات ARM64 (Little Endian)
    // هذا الكود يعني "عودة فوراً" بدون فعل شيء
    uint8_t retCode[] = {0xC0, 0x03, 0x5F, 0xD6}; 
    
    // استخدام DobbyCodePatch للكتابة الآمنة (يتخطى حماية الذاكرة)
    DobbyCodePatch((void *)address, retCode, 4);
}

// ============================================================================
// [4] نقطة التشغيل
// ============================================================================
__attribute__((constructor))
static void InitProHook() {
    
    // تنظيف الملفات (لتحسين الأداء)
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ano_tmp"] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] error:nil];

    // الانتظار 5 ثواني
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        uintptr_t slide = GetBaseAddress("ShadowTrackerExtra");
        
        if (slide != 0) {
            int count = sizeof(offsets) / sizeof(offsets[0]);
            
            for (int i = 0; i < count; i++) {
                uintptr_t targetAddr = slide + offsets[i];
                
                // 🔥 التنفيذ بطريقة الباتش (أخف وأسرع)
                ApplySafePatch(targetAddr);
            }
            
            NSLog(@"[Sovereign] ✅ Pro Patch Applied: %d offsets disabled.", count);
            
            // إشعار بسيط
            dispatch_async(dispatch_get_main_queue(), ^{
                UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 200, 30)];
                lbl.text = @"Pro Patch Active ⚡️";
                lbl.textColor = [UIColor cyanColor];
                lbl.font = [UIFont boldSystemFontOfSize:14];
                [[UIApplication sharedApplication].keyWindow addSubview:lbl];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [lbl removeFromSuperview];
                });
            });
        }
    });
}
