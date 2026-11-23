#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>

#include "api/echo_canceller3_factory.h"
#include "api/echo_canceller3_config.h"
#include "audio_processing/include/audio_processing.h"
#include "audio_processing/audio_buffer.h"
#include "audio_processing/high_pass_filter.h"

using namespace webrtc;

constexpr int kSampleRate = 16000;
constexpr int kChannels = 1;
constexpr int kSamplesPerFrame = 160; // 10 ms @ 16 kHz
constexpr int kStereoSamples = kSamplesPerFrame * 2;

int main(int argc, char* argv[]) {
  int16_t input[kStereoSamples];
  int16_t ref_mono[kSamplesPerFrame];
  int16_t rec_mono[kSamplesPerFrame];
  int16_t out_mono[kSamplesPerFrame];

  EchoCanceller3Config aec_config;
  aec_config.filter.export_linear_aec_output = true;
  aec_config.delay.default_delay = 2;

  EchoCanceller3Factory aec_factory(aec_config);
  std::unique_ptr<EchoControl> echo_controller = aec_factory.Create(kSampleRate, kChannels, kChannels);
  std::unique_ptr<HighPassFilter> hp_filter = std::make_unique<HighPassFilter>(kSampleRate, kChannels);

  StreamConfig config(kSampleRate, kChannels, false);

  auto ref_audio = std::make_unique<AudioBuffer>(
      config.sample_rate_hz(), config.num_channels(),
      config.sample_rate_hz(), config.num_channels(),
      config.sample_rate_hz(), config.num_channels());

  auto aec_audio = std::make_unique<AudioBuffer>(
      config.sample_rate_hz(), config.num_channels(),
      config.sample_rate_hz(), config.num_channels(),
      config.sample_rate_hz(), config.num_channels());

  auto aec_linear_audio = std::make_unique<AudioBuffer>(
      kSampleRate, config.num_channels(),
      kSampleRate, config.num_channels(),
      kSampleRate, config.num_channels());

  AudioFrame ref_frame, aec_frame, out_frame;

  while (true) {
    size_t read_bytes = std::fread(input, 1, sizeof(input), stdin);
    if (read_bytes < sizeof(input)) {
      break;
    }

    for (int i = 0; i < kSamplesPerFrame; ++i) {
      rec_mono[i] = input[i * 2];
      ref_mono[i] = input[i * 2 + 1];
    }

    ref_frame.UpdateFrame(0, ref_mono, kSamplesPerFrame, kSampleRate,
                          AudioFrame::kNormalSpeech, AudioFrame::kVadActive, 1);
    aec_frame.UpdateFrame(0, rec_mono, kSamplesPerFrame, kSampleRate,
                          AudioFrame::kNormalSpeech, AudioFrame::kVadActive, 1);

    ref_audio->CopyFrom(&ref_frame);
    aec_audio->CopyFrom(&aec_frame);

    ref_audio->SplitIntoFrequencyBands();
    echo_controller->AnalyzeRender(ref_audio.get());
    ref_audio->MergeFrequencyBands();

    echo_controller->AnalyzeCapture(aec_audio.get());
    aec_audio->SplitIntoFrequencyBands();
    hp_filter->Process(aec_audio.get(), true);
    echo_controller->ProcessCapture(aec_audio.get(), aec_linear_audio.get(), false);
    aec_audio->MergeFrequencyBands();

    out_frame.UpdateFrame(0, nullptr, kSamplesPerFrame, kSampleRate,
                          AudioFrame::kNormalSpeech, AudioFrame::kVadActive, 1);
    aec_linear_audio->CopyTo(&out_frame);
    std::memcpy(out_mono, out_frame.data(), sizeof(out_mono));

    if (std::fwrite(out_mono, 1, sizeof(out_mono), stdout) != sizeof(out_mono)) {
      break;
    }
    std::fflush(stdout);
  }

  return 0;
}
