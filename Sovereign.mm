#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import "dobby.h" // ⚠️ تأكد أن هذا الملف موجود في المستودع

// ============================================================================
// [1] قائمة الأوفستات الجديدة (تم استخراجها وتنظيفها)
// ============================================================================
static uintptr_t offsets[] = {
    0x0002A8B68, 0x1002A8B68, 0x101C87200, 0x101C85C80, 0x101C86DF0, 
    0x101C851DC, 0x101947E04, 0x101948928, 0x100C8293C, 0x101C42B90, 
    0x101C427F0, 0x101C41C70, 0x101C3F988, 0x1015C7284, 0x1005A47DC, 
    0x101C80474, 0x101C80710, 0x10093AE94, 0x10093F9A8, 0x101938A10, 
    0x10193821C, 0x101936D54, 0x10193504C, 0x100C82804, 0x100C827B8, 
    0x100C8270C, 0x100C81304, 0x100C80DD4, 0x100C80744, 0x1000757D4, 
    0x10007559C, 0x100075378, 0x10007599C, 0x101C86920, 0x101C83A10, 
    0x101C88F30, 0x101C87B00, 0x101C6110C, 0x101C8C5EC, 0x101C8C62C, 
    0x101C8D9F8, 0x101C8E61C, 0x101C8E65C, 0x101CA3F20, 0x101CA3EEC, 
    0x101CA3F14, 0x101CA3DF0, 0x101C8E130, 0x101C60E4C, 0x101C8E66C, 
    0x101C8E340, 0x101CA3DD0, 0x101C65284, 0x101C8DC40, 0x101C60DE4, 
    0x101C8C494, 0x101C8D920, 0x101C8D860, 0x101C60B60, 0x101D52528, 
    0x101D369A4, 0x101D4136C, 0x101D10114, 0x101D7BF94, 0x101D25238, 
    0x101D71360, 0x101D668EC, 0x101C8A0EC, 0x101C664E8, 0x101CAE120, 
    0x101C92510, 0x101C9B994, 0x101CA6AC8, 0x101CB7A94, 0x101CCB9C8, 
    0x101CD68AC, 0x101CE1614, 0x101CEE480, 0x101CBC0B8, 0x101CF9128
};

// ============================================================================
// [2] دالة "الفراغ" (Null Function)
// ============================================================================
// هذه الدالة لا تفعل شيئاً. Dobby سيجبر اللعبة على القفز إليها
// هذا يعادل وضع كود RET (0xC0035FD6) ولكن بطريقة آمنة بدون كراش
void SafeNullFunction() {
    return;
}

// ============================================================================
// [3] المحرك (ShadowTrackerExtra)
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
// [4] نقطة التشغيل
// ============================================================================
__attribute__((constructor))
static void InitSovereign() {
    
    // تنظيف مؤقت
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ano_tmp"] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] error:nil];

    // تأخير بسيط لضمان تحميل المكتبات
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        uintptr_t slide = GetBaseAddress("ShadowTrackerExtra");
        
        if (slide != 0) {
            int count = sizeof(offsets) / sizeof(offsets[0]);
            
            for (int i = 0; i < count; i++) {
                uintptr_t targetAddr = slide + offsets[i];
                
                // 🔥 تطبيق Dobby Hook
                // هذا يمنع الكراش لأنه لا يكتب فوق الذاكرة المحمية
                DobbyHook((void *)targetAddr, (void *)SafeNullFunction, NULL);
            }
            
            NSLog(@"[Sovereign] ✅ Dobby Hook Active: %d offsets protected.", count);
        }
    });
}
